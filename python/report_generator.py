"""
Report Generator Module for Retail Sales Analytics.
Exports analytics data to CSV, Excel, and JSON formats for consumption
by the web dashboard and business stakeholders.
"""

import json
import logging
from datetime import datetime
from pathlib import Path
from typing import Dict

import pandas as pd

from config import DASHBOARD_DATA_DIR, REPORT_CONFIG, REPORTS_DIR

logger = logging.getLogger(__name__)


class ReportGenerator:
    """
    Generates formatted reports from analytics data.
    Exports to CSV, JSON, and creates dashboard-ready data files.
    """

    def __init__(
        self,
        transformed_data: Dict[str, pd.DataFrame],
        kpis: Dict,
        raw_data: Dict[str, pd.DataFrame],
    ):
        """
        Initialize the report generator.

        Args:
            transformed_data: Transformed DataFrames from ETL pipeline
            kpis: KPI dictionary from KPI engine
            raw_data: Raw DataFrames for additional reporting
        """
        self.data = transformed_data
        self.kpis = kpis
        self.raw = raw_data
        self.reports_dir = REPORTS_DIR
        self.dashboard_dir = DASHBOARD_DATA_DIR
        self.generated_files = []

    def generate_all(self) -> list:
        """
        Generate all reports.

        Returns:
            List of generated file paths
        """
        logger.info("📝 Generating Reports...")

        self._generate_csv_reports()
        self._generate_dashboard_json()
        self._generate_executive_summary()

        logger.info(f"\n✅ {len(self.generated_files)} reports generated successfully")
        for f in self.generated_files:
            logger.info(f"   📄 {f}")

        return self.generated_files

    def _generate_csv_reports(self):
        """Generate CSV report files."""
        csv_exports = {
            "monthly_kpi_summary.csv": self.data.get("monthly_revenue"),
            "product_performance.csv": self.data.get("product_performance"),
            "customer_segments.csv": self.data.get("customer_segments"),
            "store_performance.csv": self.data.get("store_performance"),
            "category_summary.csv": self.data.get("category_summary"),
            "payment_analysis.csv": self.data.get("payment_analysis"),
        }

        for filename, df in csv_exports.items():
            if df is not None and len(df) > 0:
                filepath = self.reports_dir / filename
                df.to_csv(
                    filepath,
                    index=False,
                    encoding=REPORT_CONFIG["csv_encoding"],
                    float_format=REPORT_CONFIG["float_format"],
                )
                self.generated_files.append(str(filepath))
                logger.info(f"   ✅ {filename} ({len(df)} rows)")

    def _generate_dashboard_json(self):
        """
        Generate the comprehensive JSON data file for the web dashboard.
        This is the main data source for the dashboard/index.html.
        """
        logger.info("   📊 Generating dashboard JSON...")

        # Monthly revenue for line chart
        monthly = self.data.get("monthly_revenue", pd.DataFrame())
        monthly_data = []
        if len(monthly) > 0:
            for _, row in monthly.iterrows():
                monthly_data.append({
                    "month": str(row["month"]),
                    "revenue": float(row["total_revenue"]),
                    "orders": int(row["total_orders"]),
                    "customers": int(row["unique_customers"]),
                    "aov": float(row["avg_order_value"]),
                    "growth_pct": float(row["mom_growth_pct"]) if pd.notna(row.get("mom_growth_pct")) else None,
                    "moving_avg": float(row["revenue_3m_avg"]) if pd.notna(row.get("revenue_3m_avg")) else None,
                })

        # Category data for doughnut chart
        categories = self.data.get("category_summary", pd.DataFrame())
        category_data = []
        if len(categories) > 0:
            for _, row in categories.iterrows():
                category_data.append({
                    "category": row["category"],
                    "revenue": float(row["total_revenue"]),
                    "share_pct": float(row["revenue_share_pct"]),
                    "orders": int(row["total_orders"]),
                    "units": int(row["total_units"]),
                })

        # Top products for bar chart
        top_products = self.data.get("top_products", pd.DataFrame())
        products_data = []
        if len(top_products) > 0:
            for _, row in top_products.iterrows():
                products_data.append({
                    "name": row["product_name"],
                    "category": row["category"],
                    "brand": row["brand"],
                    "revenue": float(row["total_revenue"]),
                    "units": int(row["total_units_sold"]),
                    "orders": int(row["times_ordered"]),
                    "margin": float(row["margin_pct"]),
                })

        # Store data for radar chart
        stores = self.data.get("store_performance", pd.DataFrame())
        store_data = []
        if len(stores) > 0:
            for _, row in stores.iterrows():
                store_data.append({
                    "name": row["store_name"],
                    "type": row["store_type"],
                    "region": row["region"],
                    "city": row["city"],
                    "revenue": float(row["total_revenue"]),
                    "transactions": int(row["total_transactions"]),
                    "customers": int(row["unique_customers"]),
                    "avg_txn_value": float(row["avg_transaction_value"]),
                    "revenue_per_sqft": float(row["revenue_per_sqft"]),
                    "share_pct": float(row["revenue_share_pct"]),
                })

        # Customer segments
        segments = self.data.get("customer_segments", pd.DataFrame())
        segment_summary = []
        if len(segments) > 0:
            seg_grouped = segments.groupby("segment").agg(
                count=("customer_id", "count"),
                avg_spent=("total_spent", "mean"),
                avg_orders=("total_orders", "mean"),
                total_revenue=("total_spent", "sum"),
            ).reset_index()

            for _, row in seg_grouped.iterrows():
                segment_summary.append({
                    "segment": row["segment"],
                    "count": int(row["count"]),
                    "avg_spent": round(float(row["avg_spent"]), 2),
                    "avg_orders": round(float(row["avg_orders"]), 1),
                    "total_revenue": round(float(row["total_revenue"]), 2),
                })

        # Payment methods
        payments = self.data.get("payment_analysis", pd.DataFrame())
        payment_data = []
        if len(payments) > 0:
            for _, row in payments.iterrows():
                payment_data.append({
                    "method": row["payment_method"],
                    "count": int(row["transaction_count"]),
                    "revenue": float(row["total_revenue"]),
                    "pct_transactions": float(row["pct_of_transactions"]),
                    "pct_revenue": float(row["pct_of_revenue"]),
                })

        # Compile the full dashboard data object
        dashboard_data = {
            "generated_at": datetime.now().isoformat(),
            "data_period": {
                "start": str(monthly.iloc[0]["month"]) if len(monthly) > 0 else "N/A",
                "end": str(monthly.iloc[-1]["month"]) if len(monthly) > 0 else "N/A",
            },
            "kpis": self.kpis,
            "monthly_revenue": monthly_data,
            "categories": category_data,
            "top_products": products_data,
            "stores": store_data,
            "customer_segments": segment_summary,
            "payment_methods": payment_data,
        }

        # Write to dashboard data directory
        filepath = self.dashboard_dir / "analytics_data.json"
        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(dashboard_data, f, indent=2, default=str)

        self.generated_files.append(str(filepath))
        logger.info(f"   ✅ analytics_data.json (dashboard data)")

    def _generate_executive_summary(self):
        """Generate a compact executive summary JSON."""
        summary = {
            "report_title": "Retail Sales Analytics — Executive Summary",
            "generated_at": datetime.now().isoformat(),
            "highlights": {
                "total_revenue": self.kpis.get("summary", {}).get("total_revenue", 0),
                "total_orders": self.kpis.get("summary", {}).get("total_orders", 0),
                "total_customers": self.kpis.get("summary", {}).get("total_customers", 0),
                "avg_order_value": self.kpis.get("summary", {}).get("avg_order_value", 0),
                "gross_margin_pct": self.kpis.get("summary", {}).get("gross_margin_pct", 0),
                "yoy_growth_pct": self.kpis.get("growth", {}).get("yoy_growth_pct", 0),
            },
            "top_insights": [
                f"Total revenue: ${self.kpis.get('summary', {}).get('total_revenue', 0):,.2f}",
                f"YoY Growth: {self.kpis.get('growth', {}).get('yoy_growth_pct', 0):.1f}%",
                f"Best performing store: {self.kpis.get('store', {}).get('best_store', 'N/A')}",
                f"Gross margin: {self.kpis.get('summary', {}).get('gross_margin_pct', 0):.1f}%",
                f"Repeat purchase rate: {self.kpis.get('customer', {}).get('repeat_purchase_rate', 0):.1f}%",
            ],
            "kpis": self.kpis,
        }

        filepath = self.reports_dir / "executive_summary.json"
        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(summary, f, indent=2, default=str)

        self.generated_files.append(str(filepath))
        logger.info(f"   ✅ executive_summary.json")


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    from etl_pipeline import ETLPipeline
    from kpi_engine import KPIEngine

    pipeline = ETLPipeline(use_db=False)
    pipeline.extract()
    pipeline.transform()

    engine = KPIEngine(pipeline.transformed_data, pipeline.raw_data)
    kpis = engine.calculate_all()

    reporter = ReportGenerator(pipeline.transformed_data, kpis, pipeline.raw_data)
    reporter.generate_all()
