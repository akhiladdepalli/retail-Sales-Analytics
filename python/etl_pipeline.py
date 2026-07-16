"""
ETL Pipeline Module for Retail Sales Analytics.
Extracts data from source (PostgreSQL or generated DataFrames),
transforms for analytics, and loads into output formats.
"""

import logging
from typing import Dict, Optional

import numpy as np
import pandas as pd

from config import ANALYTICS_CONFIG, DB_CONFIG
from data_generator import RetailDataGenerator
from db_connector import DatabaseConnector

logger = logging.getLogger(__name__)


class ETLPipeline:
    """
    Extract-Transform-Load pipeline for retail analytics data.
    Supports both PostgreSQL and standalone (in-memory) modes.
    """

    def __init__(self, use_db: bool = False):
        """
        Initialize the ETL pipeline.

        Args:
            use_db: If True, attempt to connect to PostgreSQL.
                    If False, generate data in-memory.
        """
        self.use_db = use_db
        self.db: Optional[DatabaseConnector] = None
        self.raw_data: Dict[str, pd.DataFrame] = {}
        self.transformed_data: Dict[str, pd.DataFrame] = {}
        self.analytics_config = ANALYTICS_CONFIG

        if use_db:
            self.db = DatabaseConnector(DB_CONFIG)
            if not self.db.is_available:
                logger.warning("Database unavailable — falling back to standalone mode")
                self.use_db = False

    def extract(self) -> Dict[str, pd.DataFrame]:
        """
        Extract data from source.

        Returns:
            Dictionary of raw DataFrames
        """
        logger.info("📥 EXTRACT PHASE — Loading data...")

        if self.use_db and self.db and self.db.is_available:
            self.raw_data = self._extract_from_db()
        else:
            self.raw_data = self._extract_from_generator()

        for name, df in self.raw_data.items():
            logger.info(f"   📦 {name}: {len(df):,} rows × {len(df.columns)} columns")

        return self.raw_data

    def _extract_from_db(self) -> Dict[str, pd.DataFrame]:
        """Extract data from PostgreSQL database."""
        schema = DB_CONFIG["schema"]
        tables = {
            "stores": f"SELECT * FROM {schema}.stores",
            "products": f"SELECT * FROM {schema}.products",
            "customers": f"SELECT * FROM {schema}.customers",
            "transactions": f"SELECT * FROM {schema}.transactions",
            "transaction_items": f"SELECT * FROM {schema}.transaction_items",
        }

        data = {}
        for name, query in tables.items():
            data[name] = self.db.execute_query(query)
            logger.info(f"   Extracted {name}: {len(data[name]):,} rows")

        return data

    def _extract_from_generator(self) -> Dict[str, pd.DataFrame]:
        """Generate data in-memory using the data generator."""
        logger.info("   🏭 Generating synthetic data (standalone mode)...")
        generator = RetailDataGenerator()
        return generator.generate_all()

    def transform(self) -> Dict[str, pd.DataFrame]:
        """
        Transform raw data into analytics-ready datasets.

        Returns:
            Dictionary of transformed DataFrames
        """
        logger.info("\n🔄 TRANSFORM PHASE — Processing data...")

        if not self.raw_data:
            raise ValueError("No data to transform. Run extract() first.")

        # Get references to raw data
        transactions = self.raw_data["transactions"].copy()
        items = self.raw_data["transaction_items"].copy()
        products = self.raw_data["products"].copy()
        customers = self.raw_data["customers"].copy()
        stores = self.raw_data["stores"].copy()

        # Filter to completed transactions for most analytics
        completed = transactions[transactions["order_status"] == "Completed"].copy()

        # 1. Monthly Revenue Summary
        self.transformed_data["monthly_revenue"] = self._transform_monthly_revenue(completed)
        logger.info("   ✅ Monthly revenue summary")

        # 2. Product Performance
        self.transformed_data["product_performance"] = self._transform_product_performance(
            completed, items, products
        )
        logger.info("   ✅ Product performance rankings")

        # 3. Category Summary
        self.transformed_data["category_summary"] = self._transform_category_summary(
            completed, items, products
        )
        logger.info("   ✅ Category summary")

        # 4. Customer Segments (RFM)
        self.transformed_data["customer_segments"] = self._transform_customer_segments(
            completed, items, customers
        )
        logger.info("   ✅ Customer segmentation (RFM)")

        # 5. Store Performance
        self.transformed_data["store_performance"] = self._transform_store_performance(
            completed, items, stores
        )
        logger.info("   ✅ Store performance metrics")

        # 6. Payment Method Analysis
        self.transformed_data["payment_analysis"] = self._transform_payment_analysis(completed)
        logger.info("   ✅ Payment method analysis")

        # 7. Daily Sales (for time series charts)
        self.transformed_data["daily_sales"] = self._transform_daily_sales(completed)
        logger.info("   ✅ Daily sales time series")

        # 8. Top Products
        self.transformed_data["top_products"] = (
            self.transformed_data["product_performance"]
            .nlargest(self.analytics_config["top_n_products"], "total_revenue")
        )
        logger.info("   ✅ Top products identified")

        # 9. Order Status Summary
        self.transformed_data["order_status"] = self._transform_order_status(transactions)
        logger.info("   ✅ Order status summary")

        return self.transformed_data

    def _transform_monthly_revenue(self, transactions: pd.DataFrame) -> pd.DataFrame:
        """Calculate monthly revenue metrics with MoM growth."""
        transactions["month"] = transactions["transaction_date"].dt.to_period("M")

        monthly = transactions.groupby("month").agg(
            total_orders=("transaction_id", "nunique"),
            unique_customers=("customer_id", "nunique"),
            total_revenue=("total_amount", "sum"),
            avg_order_value=("total_amount", "mean"),
            total_discounts=("discount_amount", "sum"),
        ).reset_index()

        monthly["total_revenue"] = monthly["total_revenue"].round(2)
        monthly["avg_order_value"] = monthly["avg_order_value"].round(2)
        monthly["total_discounts"] = monthly["total_discounts"].round(2)

        # Month-over-Month growth
        monthly["prev_month_revenue"] = monthly["total_revenue"].shift(1)
        monthly["mom_growth_pct"] = (
            (monthly["total_revenue"] - monthly["prev_month_revenue"])
            / monthly["prev_month_revenue"] * 100
        ).round(2)

        # 3-month moving average
        monthly["revenue_3m_avg"] = (
            monthly["total_revenue"].rolling(window=3, min_periods=1).mean().round(2)
        )

        monthly["month"] = monthly["month"].astype(str)
        return monthly

    def _transform_product_performance(
        self, transactions: pd.DataFrame, items: pd.DataFrame, products: pd.DataFrame
    ) -> pd.DataFrame:
        """Calculate product-level performance metrics."""
        # Join items with transactions and products
        merged = items.merge(
            transactions[["transaction_id", "customer_id", "transaction_date"]],
            on="transaction_id",
            how="inner",
        ).merge(
            products[["product_id", "product_name", "category", "sub_category",
                      "brand", "unit_cost", "margin_pct"]],
            on="product_id",
            how="inner",
        )

        product_stats = merged.groupby(
            ["product_id", "product_name", "category", "sub_category", "brand", "margin_pct"]
        ).agg(
            times_ordered=("transaction_id", "nunique"),
            total_units_sold=("quantity", "sum"),
            total_revenue=("line_total", "sum"),
            avg_line_total=("line_total", "mean"),
            avg_discount=("discount_pct", "mean"),
            unique_buyers=("customer_id", "nunique"),
        ).reset_index()

        product_stats["total_revenue"] = product_stats["total_revenue"].round(2)
        product_stats["avg_line_total"] = product_stats["avg_line_total"].round(2)
        product_stats["avg_discount"] = product_stats["avg_discount"].round(2)

        # Calculate total cost and gross profit
        product_stats = product_stats.merge(
            products[["product_id", "unit_cost"]],
            on="product_id",
            how="left",
        )
        product_stats["total_cost"] = (
            product_stats["total_units_sold"] * product_stats["unit_cost"]
        ).round(2)
        product_stats["gross_profit"] = (
            product_stats["total_revenue"] - product_stats["total_cost"]
        ).round(2)

        # Rankings
        product_stats["revenue_rank"] = product_stats["total_revenue"].rank(
            ascending=False, method="min"
        ).astype(int)
        product_stats["units_rank"] = product_stats["total_units_sold"].rank(
            ascending=False, method="min"
        ).astype(int)

        grand_total = product_stats["total_revenue"].sum()
        product_stats["revenue_contribution_pct"] = (
            product_stats["total_revenue"] / grand_total * 100
        ).round(4)

        return product_stats.sort_values("revenue_rank")

    def _transform_category_summary(
        self, transactions: pd.DataFrame, items: pd.DataFrame, products: pd.DataFrame
    ) -> pd.DataFrame:
        """Calculate category-level summary."""
        merged = items.merge(
            transactions[["transaction_id"]], on="transaction_id", how="inner"
        ).merge(
            products[["product_id", "category", "unit_cost"]], on="product_id", how="inner"
        )

        cat_stats = merged.groupby("category").agg(
            product_count=("product_id", "nunique"),
            total_orders=("transaction_id", "nunique"),
            total_units=("quantity", "sum"),
            total_revenue=("line_total", "sum"),
        ).reset_index()

        cat_stats["total_revenue"] = cat_stats["total_revenue"].round(2)
        grand_total = cat_stats["total_revenue"].sum()
        cat_stats["revenue_share_pct"] = (
            cat_stats["total_revenue"] / grand_total * 100
        ).round(2)
        cat_stats["revenue_rank"] = cat_stats["total_revenue"].rank(
            ascending=False, method="min"
        ).astype(int)

        return cat_stats.sort_values("revenue_rank")

    def _transform_customer_segments(
        self, transactions: pd.DataFrame, items: pd.DataFrame, customers: pd.DataFrame
    ) -> pd.DataFrame:
        """RFM customer segmentation using Pandas."""
        now = transactions["transaction_date"].max()

        customer_metrics = transactions.groupby("customer_id").agg(
            total_orders=("transaction_id", "nunique"),
            total_spent=("total_amount", "sum"),
            avg_order_value=("total_amount", "mean"),
            last_purchase=("transaction_date", "max"),
        ).reset_index()

        customer_metrics["recency_days"] = (
            now - customer_metrics["last_purchase"]
        ).dt.days

        customer_metrics["total_spent"] = customer_metrics["total_spent"].round(2)
        customer_metrics["avg_order_value"] = customer_metrics["avg_order_value"].round(2)

        # RFM Scoring (quintiles)
        q = self.analytics_config["rfm_quantiles"]
        customer_metrics["r_score"] = pd.qcut(
            customer_metrics["recency_days"], q=q, labels=range(q, 0, -1), duplicates="drop"
        ).astype(int)
        customer_metrics["f_score"] = pd.qcut(
            customer_metrics["total_orders"].rank(method="first"),
            q=q, labels=range(1, q + 1), duplicates="drop"
        ).astype(int)
        customer_metrics["m_score"] = pd.qcut(
            customer_metrics["total_spent"].rank(method="first"),
            q=q, labels=range(1, q + 1), duplicates="drop"
        ).astype(int)

        customer_metrics["rfm_total"] = (
            customer_metrics["r_score"] +
            customer_metrics["f_score"] +
            customer_metrics["m_score"]
        )

        # Segment assignment
        def assign_segment(row):
            r, f, m = row["r_score"], row["f_score"], row["m_score"]
            if r >= 4 and f >= 4 and m >= 4:
                return "Champions"
            elif r >= 3 and f >= 3 and m >= 3:
                return "Loyal Customers"
            elif r >= 4 and f <= 2:
                return "New Customers"
            elif r >= 3 and f >= 2 and m >= 2:
                return "Potential Loyalists"
            elif r <= 2 and f >= 3 and m >= 3:
                return "At Risk"
            elif r <= 2 and f >= 4 and m >= 4:
                return "Cannot Lose Them"
            elif r <= 2 and f <= 2:
                return "Hibernating"
            else:
                return "Need Attention"

        customer_metrics["segment"] = customer_metrics.apply(assign_segment, axis=1)

        # Merge with customer info
        customer_metrics = customer_metrics.merge(
            customers[["customer_id", "first_name", "last_name", "city",
                       "state", "loyalty_tier"]],
            on="customer_id",
            how="left",
        )

        return customer_metrics

    def _transform_store_performance(
        self, transactions: pd.DataFrame, items: pd.DataFrame, stores: pd.DataFrame
    ) -> pd.DataFrame:
        """Calculate store-level performance metrics."""
        store_txn = transactions.merge(
            stores[["store_id", "store_name", "store_type", "city", "state",
                    "region", "square_footage"]],
            on="store_id",
            how="inner",
        )

        store_stats = store_txn.groupby(
            ["store_id", "store_name", "store_type", "city", "state",
             "region", "square_footage"]
        ).agg(
            total_transactions=("transaction_id", "nunique"),
            unique_customers=("customer_id", "nunique"),
            total_revenue=("total_amount", "sum"),
            avg_transaction_value=("total_amount", "mean"),
            total_discounts=("discount_amount", "sum"),
        ).reset_index()

        store_stats["total_revenue"] = store_stats["total_revenue"].round(2)
        store_stats["avg_transaction_value"] = store_stats["avg_transaction_value"].round(2)
        store_stats["total_discounts"] = store_stats["total_discounts"].round(2)

        store_stats["revenue_per_sqft"] = (
            store_stats["total_revenue"] / store_stats["square_footage"]
        ).round(2)

        store_stats["revenue_rank"] = store_stats["total_revenue"].rank(
            ascending=False, method="min"
        ).astype(int)

        grand_total = store_stats["total_revenue"].sum()
        store_stats["revenue_share_pct"] = (
            store_stats["total_revenue"] / grand_total * 100
        ).round(2)

        return store_stats.sort_values("revenue_rank")

    def _transform_payment_analysis(self, transactions: pd.DataFrame) -> pd.DataFrame:
        """Analyze payment method distribution."""
        payment_stats = transactions.groupby("payment_method").agg(
            transaction_count=("transaction_id", "count"),
            total_revenue=("total_amount", "sum"),
            avg_order_value=("total_amount", "mean"),
        ).reset_index()

        payment_stats["total_revenue"] = payment_stats["total_revenue"].round(2)
        payment_stats["avg_order_value"] = payment_stats["avg_order_value"].round(2)

        total_txns = payment_stats["transaction_count"].sum()
        total_rev = payment_stats["total_revenue"].sum()
        payment_stats["pct_of_transactions"] = (
            payment_stats["transaction_count"] / total_txns * 100
        ).round(2)
        payment_stats["pct_of_revenue"] = (
            payment_stats["total_revenue"] / total_rev * 100
        ).round(2)

        return payment_stats.sort_values("total_revenue", ascending=False)

    def _transform_daily_sales(self, transactions: pd.DataFrame) -> pd.DataFrame:
        """Calculate daily sales for time series charts."""
        transactions["date"] = transactions["transaction_date"].dt.date

        daily = transactions.groupby("date").agg(
            total_orders=("transaction_id", "nunique"),
            total_revenue=("total_amount", "sum"),
            unique_customers=("customer_id", "nunique"),
        ).reset_index()

        daily["total_revenue"] = daily["total_revenue"].round(2)
        daily["date"] = pd.to_datetime(daily["date"])

        # 7-day moving average
        daily["revenue_7d_avg"] = daily["total_revenue"].rolling(
            window=7, min_periods=1
        ).mean().round(2)

        return daily.sort_values("date")

    def _transform_order_status(self, transactions: pd.DataFrame) -> pd.DataFrame:
        """Summarize order statuses."""
        status_stats = transactions.groupby("order_status").agg(
            order_count=("transaction_id", "count"),
            total_amount=("total_amount", "sum"),
            avg_amount=("total_amount", "mean"),
        ).reset_index()

        total = status_stats["order_count"].sum()
        status_stats["pct_of_total"] = (
            status_stats["order_count"] / total * 100
        ).round(2)

        return status_stats.sort_values("order_count", ascending=False)

    def load(self, output_format: str = "dict") -> dict:
        """
        Load transformed data into the desired output format.

        Args:
            output_format: 'dict' returns data dict, 'db' loads to PostgreSQL

        Returns:
            Dictionary of transformed DataFrames
        """
        logger.info("\n📤 LOAD PHASE — Preparing outputs...")

        if not self.transformed_data:
            raise ValueError("No transformed data. Run transform() first.")

        logger.info(f"   📊 {len(self.transformed_data)} datasets ready for export")
        for name, df in self.transformed_data.items():
            logger.info(f"      • {name}: {len(df):,} rows")

        return self.transformed_data

    def run(self) -> Dict[str, pd.DataFrame]:
        """Execute the full ETL pipeline: Extract → Transform → Load."""
        logger.info("=" * 60)
        logger.info("🚀 RETAIL SALES ANALYTICS ETL PIPELINE")
        logger.info("=" * 60)

        self.extract()
        self.transform()
        result = self.load()

        logger.info("\n" + "=" * 60)
        logger.info("✅ ETL PIPELINE COMPLETE")
        logger.info("=" * 60)

        return result


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    pipeline = ETLPipeline(use_db=False)
    results = pipeline.run()
