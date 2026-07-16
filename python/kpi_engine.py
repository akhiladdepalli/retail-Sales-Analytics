"""
KPI Engine Module for Retail Sales Analytics.
Calculates enterprise-level business KPIs from transformed data using Pandas.
"""

import logging
from typing import Dict

import numpy as np
import pandas as pd

from config import ANALYTICS_CONFIG

logger = logging.getLogger(__name__)


class KPIEngine:
    """
    Calculates comprehensive business KPIs from analytics data.
    Produces a structured KPI dictionary suitable for dashboard consumption.
    """

    def __init__(self, transformed_data: Dict[str, pd.DataFrame], raw_data: Dict[str, pd.DataFrame]):
        """
        Initialize the KPI engine with transformed analytics data.

        Args:
            transformed_data: Dictionary of transformed DataFrames from ETL pipeline
            raw_data: Dictionary of raw DataFrames
        """
        self.data = transformed_data
        self.raw = raw_data
        self.kpis: Dict = {}

    def calculate_all(self) -> Dict:
        """
        Calculate all business KPIs.

        Returns:
            Comprehensive dictionary of KPIs organized by category
        """
        logger.info("📈 Calculating Business KPIs...")

        self.kpis = {
            "summary": self._calculate_summary_kpis(),
            "revenue": self._calculate_revenue_kpis(),
            "customer": self._calculate_customer_kpis(),
            "product": self._calculate_product_kpis(),
            "store": self._calculate_store_kpis(),
            "growth": self._calculate_growth_kpis(),
        }

        logger.info("✅ All KPIs calculated successfully")
        return self.kpis

    def _calculate_summary_kpis(self) -> Dict:
        """Top-level summary KPIs for the executive dashboard."""
        transactions = self.raw["transactions"]
        completed = transactions[transactions["order_status"] == "Completed"]
        items = self.raw["transaction_items"]

        total_revenue = float(completed["total_amount"].sum())
        total_orders = int(completed["transaction_id"].nunique())
        total_customers = int(completed["customer_id"].nunique())
        total_units = int(
            items[items["transaction_id"].isin(completed["transaction_id"])]["quantity"].sum()
        )
        avg_order_value = float(completed["total_amount"].mean())
        total_discounts = float(completed["discount_amount"].sum())

        # Gross margin
        merged_items = items.merge(
            self.raw["products"][["product_id", "unit_cost"]],
            on="product_id", how="left"
        )
        total_cogs = float((merged_items["quantity"] * merged_items["unit_cost"]).sum())
        total_line_revenue = float(merged_items["line_total"].sum())
        gross_margin_pct = round(
            (total_line_revenue - total_cogs) / total_line_revenue * 100, 2
        ) if total_line_revenue > 0 else 0

        return {
            "total_revenue": round(total_revenue, 2),
            "total_orders": total_orders,
            "total_customers": total_customers,
            "total_units_sold": total_units,
            "avg_order_value": round(avg_order_value, 2),
            "total_discounts": round(total_discounts, 2),
            "gross_margin_pct": gross_margin_pct,
            "revenue_per_customer": round(total_revenue / max(total_customers, 1), 2),
            "units_per_order": round(total_units / max(total_orders, 1), 1),
        }

    def _calculate_revenue_kpis(self) -> Dict:
        """Revenue-specific KPIs."""
        monthly = self.data["monthly_revenue"]

        if len(monthly) >= 2:
            latest_month_rev = float(monthly.iloc[-1]["total_revenue"])
            prev_month_rev = float(monthly.iloc[-2]["total_revenue"])
            mom_growth = round(
                (latest_month_rev - prev_month_rev) / prev_month_rev * 100, 2
            ) if prev_month_rev > 0 else 0
        else:
            latest_month_rev = float(monthly.iloc[-1]["total_revenue"]) if len(monthly) > 0 else 0
            mom_growth = 0

        # YTD Revenue
        monthly_copy = monthly.copy()
        monthly_copy["year"] = monthly_copy["month"].str[:4]
        latest_year = monthly_copy["year"].max()
        ytd_revenue = float(
            monthly_copy[monthly_copy["year"] == latest_year]["total_revenue"].sum()
        )

        # Best and worst months
        best_month = monthly.loc[monthly["total_revenue"].idxmax()]
        worst_month = monthly.loc[monthly["total_revenue"].idxmin()]

        # Average monthly revenue
        avg_monthly_revenue = float(monthly["total_revenue"].mean())

        return {
            "latest_month_revenue": round(latest_month_rev, 2),
            "mom_growth_pct": mom_growth,
            "ytd_revenue": round(ytd_revenue, 2),
            "avg_monthly_revenue": round(avg_monthly_revenue, 2),
            "best_month": {
                "month": str(best_month["month"]),
                "revenue": round(float(best_month["total_revenue"]), 2),
            },
            "worst_month": {
                "month": str(worst_month["month"]),
                "revenue": round(float(worst_month["total_revenue"]), 2),
            },
        }

    def _calculate_customer_kpis(self) -> Dict:
        """Customer-specific KPIs."""
        segments = self.data["customer_segments"]
        transactions = self.raw["transactions"]
        completed = transactions[transactions["order_status"] == "Completed"]

        total_customers = len(segments)
        segment_counts = segments["segment"].value_counts().to_dict()

        # Customer lifetime value distribution
        clv_stats = {
            "mean": round(float(segments["total_spent"].mean()), 2),
            "median": round(float(segments["total_spent"].median()), 2),
            "std": round(float(segments["total_spent"].std()), 2),
            "max": round(float(segments["total_spent"].max()), 2),
            "min": round(float(segments["total_spent"].min()), 2),
        }

        # Repeat purchase rate
        orders_per_customer = segments["total_orders"]
        repeat_customers = int((orders_per_customer > 1).sum())
        repeat_rate = round(repeat_customers / max(total_customers, 1) * 100, 2)

        # Loyalty tier distribution
        tier_dist = segments["loyalty_tier"].value_counts().to_dict()

        return {
            "total_active_customers": total_customers,
            "segment_distribution": segment_counts,
            "clv_stats": clv_stats,
            "repeat_purchase_rate": repeat_rate,
            "repeat_customers": repeat_customers,
            "loyalty_tier_distribution": tier_dist,
            "avg_orders_per_customer": round(float(orders_per_customer.mean()), 1),
        }

    def _calculate_product_kpis(self) -> Dict:
        """Product-specific KPIs."""
        products = self.data["product_performance"]
        categories = self.data["category_summary"]

        top_10 = products.nlargest(10, "total_revenue")

        return {
            "total_products_sold": int(products["product_id"].nunique()),
            "top_products": [
                {
                    "name": row["product_name"],
                    "category": row["category"],
                    "revenue": round(float(row["total_revenue"]), 2),
                    "units": int(row["total_units_sold"]),
                    "rank": int(row["revenue_rank"]),
                }
                for _, row in top_10.iterrows()
            ],
            "category_breakdown": [
                {
                    "category": row["category"],
                    "revenue": round(float(row["total_revenue"]), 2),
                    "share_pct": float(row["revenue_share_pct"]),
                    "order_count": int(row["total_orders"]),
                }
                for _, row in categories.iterrows()
            ],
            "avg_revenue_per_product": round(float(products["total_revenue"].mean()), 2),
        }

    def _calculate_store_kpis(self) -> Dict:
        """Store-specific KPIs."""
        stores = self.data["store_performance"]

        return {
            "total_stores": int(len(stores)),
            "store_rankings": [
                {
                    "name": row["store_name"],
                    "type": row["store_type"],
                    "region": row["region"],
                    "revenue": round(float(row["total_revenue"]), 2),
                    "transactions": int(row["total_transactions"]),
                    "customers": int(row["unique_customers"]),
                    "revenue_per_sqft": round(float(row["revenue_per_sqft"]), 2),
                    "rank": int(row["revenue_rank"]),
                    "share_pct": float(row["revenue_share_pct"]),
                }
                for _, row in stores.iterrows()
            ],
            "avg_revenue_per_store": round(float(stores["total_revenue"].mean()), 2),
            "best_store": stores.iloc[0]["store_name"] if len(stores) > 0 else "N/A",
        }

    def _calculate_growth_kpis(self) -> Dict:
        """Growth and trend KPIs."""
        monthly = self.data["monthly_revenue"]

        if len(monthly) < 2:
            return {"message": "Insufficient data for growth analysis"}

        monthly_copy = monthly.copy()
        monthly_copy["year"] = monthly_copy["month"].str[:4]

        # Year-over-year growth
        yearly_revenue = monthly_copy.groupby("year")["total_revenue"].sum()
        if len(yearly_revenue) >= 2:
            years = sorted(yearly_revenue.index)
            yoy_growth = round(
                (yearly_revenue[years[-1]] - yearly_revenue[years[-2]])
                / yearly_revenue[years[-2]] * 100, 2
            )
        else:
            yoy_growth = 0

        # Quarterly revenue
        monthly_copy["quarter"] = monthly_copy["month"].str[5:7].astype(int).apply(
            lambda m: f"Q{(m - 1) // 3 + 1}"
        )
        monthly_copy["year_quarter"] = monthly_copy["year"] + "-" + monthly_copy["quarter"]
        quarterly = monthly_copy.groupby("year_quarter")["total_revenue"].sum().round(2)

        # Average MoM growth
        growth_values = monthly["mom_growth_pct"].dropna()
        avg_mom_growth = round(float(growth_values.mean()), 2) if len(growth_values) > 0 else 0

        return {
            "yoy_growth_pct": float(yoy_growth),
            "avg_mom_growth_pct": avg_mom_growth,
            "quarterly_revenue": {k: round(float(v), 2) for k, v in quarterly.items()},
            "revenue_trend": "📈 Growing" if avg_mom_growth > 0 else "📉 Declining",
        }


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    from etl_pipeline import ETLPipeline

    pipeline = ETLPipeline(use_db=False)
    pipeline.extract()
    pipeline.transform()

    engine = KPIEngine(pipeline.transformed_data, pipeline.raw_data)
    kpis = engine.calculate_all()

    import json
    print(json.dumps(kpis, indent=2, default=str))
