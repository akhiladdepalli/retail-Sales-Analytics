"""
Configuration module for the Retail Sales Analytics Pipeline.
Centralizes all settings for database connections, file paths, and analytics parameters.
"""

import os
from pathlib import Path

# ============================================================================
# PROJECT PATHS
# ============================================================================
PROJECT_ROOT = Path(__file__).parent.parent
PYTHON_DIR = Path(__file__).parent
DATABASE_DIR = PROJECT_ROOT / "database"
DASHBOARD_DIR = PROJECT_ROOT / "dashboard"
REPORTS_DIR = PROJECT_ROOT / "reports"
DASHBOARD_DATA_DIR = DASHBOARD_DIR / "data"

# Ensure output directories exist
REPORTS_DIR.mkdir(parents=True, exist_ok=True)
DASHBOARD_DATA_DIR.mkdir(parents=True, exist_ok=True)

# ============================================================================
# DATABASE CONFIGURATION
# ============================================================================
DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "5432")),
    "database": os.getenv("DB_NAME", "retail_analytics"),
    "user": os.getenv("DB_USER", "postgres"),
    "password": os.getenv("DB_PASSWORD", "postgres"),
    "schema": "retail_analytics",
}

# ============================================================================
# DATA GENERATION PARAMETERS
# ============================================================================
DATA_CONFIG = {
    "num_customers": 200,
    "num_products": 120,
    "num_stores": 10,
    "date_range_start": "2024-01-01",
    "date_range_end": "2025-12-31",
    "base_monthly_transactions": 85,
    "seasonal_multipliers": {
        1: 0.70,   # January — post-holiday dip
        2: 0.75,   # February
        3: 0.90,   # March — spring recovery
        4: 0.95,   # April
        5: 1.00,   # May
        6: 1.15,   # June — summer peak
        7: 1.10,   # July
        8: 1.00,   # August
        9: 0.95,   # September
        10: 1.00,  # October
        11: 1.40,  # November — holiday ramp
        12: 1.55,  # December — peak holiday
    },
    "yoy_growth_rate": 0.12,  # 12% year-over-year growth
}

# ============================================================================
# ANALYTICS PARAMETERS
# ============================================================================
ANALYTICS_CONFIG = {
    "tax_rate": 0.0825,          # 8.25%
    "rfm_quantiles": 5,          # Quintile scoring for RFM
    "top_n_products": 10,        # Top N products in reports
    "top_n_customers": 20,       # Top N customers in reports
    "moving_avg_window": 3,      # 3-month moving average
    "high_value_threshold": 500, # Orders above this are "high-value"
}

# ============================================================================
# REPORT CONFIGURATION
# ============================================================================
REPORT_CONFIG = {
    "csv_encoding": "utf-8-sig",  # BOM for Excel compatibility
    "float_format": "%.2f",
    "date_format": "%Y-%m-%d",
    "export_formats": ["csv", "json"],
}

# ============================================================================
# PRODUCT CATEGORIES AND BRANDS
# ============================================================================
CATEGORIES = [
    "Electronics", "Clothing", "Home & Garden", "Sports & Fitness",
    "Beauty", "Books & Media", "Food & Beverages", "Toys & Games"
]

REGIONS = ["Northeast", "Southeast", "Midwest", "Southwest", "West"]

PAYMENT_METHODS = [
    "Credit Card", "Debit Card", "Cash",
    "Mobile Payment", "Gift Card", "Store Credit"
]

LOYALTY_TIERS = ["Bronze", "Silver", "Gold", "Platinum"]

STORE_TYPES = ["Flagship", "Standard", "Outlet", "Express"]
