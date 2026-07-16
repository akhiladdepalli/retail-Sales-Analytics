"""
Main Entry Point for the Retail Sales Analytics Pipeline.
Orchestrates data generation, ETL processing, KPI calculation, and report generation.

Usage:
    python main.py                          # Run full pipeline (standalone mode)
    python main.py --db                     # Run with PostgreSQL database
    python main.py --generate-only          # Only generate data, no reports
    python main.py --reports-only           # Only generate reports from existing data
"""

import argparse
import logging
import os
import sys
import time
from datetime import datetime

from config import DASHBOARD_DATA_DIR, REPORTS_DIR
from data_generator import RetailDataGenerator
from etl_pipeline import ETLPipeline
from kpi_engine import KPIEngine
from report_generator import ReportGenerator

# Fix Windows encoding issues
if sys.platform == "win32":
    os.environ.setdefault("PYTHONIOENCODING", "utf-8")
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass


def setup_logging(verbose: bool = False):
    """Configure logging with timestamp and level."""
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format="%(message)s",
        handlers=[logging.StreamHandler(sys.stdout)],
    )


def print_banner():
    """Print the application banner."""
    banner = """
================================================================
                                                                
   RETAIL SALES ANALYTICS PIPELINE                       
                                                                
   Enterprise-Grade Data Analytics with Python & Pandas       
   Version 1.0.0                                              
                                                                
================================================================
    """
    print(banner)


def print_summary(kpis: dict, duration: float):
    """Print a formatted summary of key results."""
    summary = kpis.get("summary", {})
    growth = kpis.get("growth", {})
    store = kpis.get("store", {})
    customer = kpis.get("customer", {})

    print("\n" + "=" * 60)
    print("  ANALYTICS SUMMARY")
    print("=" * 60)

    print(f"  Total Revenue:      ${summary.get('total_revenue', 0):>14,.2f}")
    print(f"  Total Orders:       {summary.get('total_orders', 0):>14,}")
    print(f"  Total Customers:    {summary.get('total_customers', 0):>14,}")
    print(f"  Avg Order Value:    ${summary.get('avg_order_value', 0):>14,.2f}")
    print(f"  Gross Margin:       {summary.get('gross_margin_pct', 0):>13.1f}%")
    print(f"  YoY Growth:         {growth.get('yoy_growth_pct', 0):>13.1f}%")
    print(f"  Repeat Rate:        {customer.get('repeat_purchase_rate', 0):>13.1f}%")
    print(f"  Best Store:         {store.get('best_store', 'N/A'):>20}")
    print(f"  Pipeline Duration:  {duration:>13.2f}s")
    print("=" * 60)


def run_pipeline(use_db: bool = False):
    """
    Execute the full analytics pipeline.

    Args:
        use_db: If True, connect to PostgreSQL. Otherwise, use standalone mode.

    Returns:
        Tuple of (kpis, generated_files)
    """
    start_time = time.time()

    # Step 1: ETL Pipeline
    print("\n🔷 STEP 1/3: ETL Pipeline")
    print("-" * 40)
    pipeline = ETLPipeline(use_db=use_db)
    pipeline.extract()
    pipeline.transform()

    # Step 2: KPI Calculation
    print("\n🔷 STEP 2/3: KPI Calculation")
    print("-" * 40)
    kpi_engine = KPIEngine(pipeline.transformed_data, pipeline.raw_data)
    kpis = kpi_engine.calculate_all()

    # Step 3: Report Generation
    print("\n🔷 STEP 3/3: Report Generation")
    print("-" * 40)
    reporter = ReportGenerator(pipeline.transformed_data, kpis, pipeline.raw_data)
    files = reporter.generate_all()

    duration = time.time() - start_time
    print_summary(kpis, duration)

    return kpis, files


def main():
    """Main entry point with CLI argument parsing."""
    parser = argparse.ArgumentParser(
        description="Retail Sales Analytics Pipeline",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python main.py                   Run full pipeline (standalone mode)
  python main.py --db              Run with PostgreSQL database
  python main.py --generate-only   Only generate synthetic data
  python main.py -v                Run with verbose logging
        """,
    )

    parser.add_argument(
        "--db", action="store_true",
        help="Connect to PostgreSQL database instead of generating data",
    )
    parser.add_argument(
        "--generate-only", action="store_true",
        help="Only generate synthetic data without processing",
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true",
        help="Enable verbose/debug logging",
    )

    args = parser.parse_args()
    setup_logging(args.verbose)
    print_banner()

    print(f"🕐 Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"📂 Reports directory: {REPORTS_DIR}")
    print(f"📊 Dashboard data: {DASHBOARD_DATA_DIR}")
    mode = "PostgreSQL" if args.db else "Standalone (in-memory)"
    print(f"🔧 Mode: {mode}")

    if args.generate_only:
        print("\n🏭 Generating synthetic data only...")
        generator = RetailDataGenerator()
        data = generator.generate_all()
        print("\n✅ Data generation complete!")
        for name, df in data.items():
            print(f"   {name}: {len(df):,} rows")
    else:
        kpis, files = run_pipeline(use_db=args.db)
        print(f"\n🎉 Pipeline complete! {len(files)} files generated.")
        print("📊 Open dashboard/index.html in your browser to view the dashboard.")


if __name__ == "__main__":
    main()
