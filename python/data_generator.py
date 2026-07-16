"""
Synthetic Data Generator for Retail Sales Analytics.
Generates realistic retail transaction data using Pandas with seasonal patterns,
customer demographics, and product catalogs — no database required.
"""

import logging
from datetime import datetime, timedelta
from typing import Dict, Tuple

import numpy as np
import pandas as pd

from config import (
    CATEGORIES, DATA_CONFIG, LOYALTY_TIERS, PAYMENT_METHODS,
    REGIONS, STORE_TYPES,
)

logger = logging.getLogger(__name__)

# Reproducible results
np.random.seed(42)


class RetailDataGenerator:
    """
    Generates a complete set of realistic retail analytics data.
    All data is generated as Pandas DataFrames — no database required.
    """

    def __init__(self, config: dict = None):
        self.config = config or DATA_CONFIG
        self.stores_df: pd.DataFrame = pd.DataFrame()
        self.products_df: pd.DataFrame = pd.DataFrame()
        self.customers_df: pd.DataFrame = pd.DataFrame()
        self.transactions_df: pd.DataFrame = pd.DataFrame()
        self.items_df: pd.DataFrame = pd.DataFrame()

    def generate_all(self) -> Dict[str, pd.DataFrame]:
        """
        Generate all datasets and return as a dictionary of DataFrames.

        Returns:
            Dictionary with keys: stores, products, customers, transactions, transaction_items
        """
        logger.info("🏭 Starting data generation...")

        self.stores_df = self._generate_stores()
        logger.info(f"   ✅ Stores: {len(self.stores_df)} records")

        self.products_df = self._generate_products()
        logger.info(f"   ✅ Products: {len(self.products_df)} records")

        self.customers_df = self._generate_customers()
        logger.info(f"   ✅ Customers: {len(self.customers_df)} records")

        self.transactions_df, self.items_df = self._generate_transactions()
        logger.info(f"   ✅ Transactions: {len(self.transactions_df)} records")
        logger.info(f"   ✅ Transaction Items: {len(self.items_df)} records")

        logger.info("🎉 Data generation complete!")

        return {
            "stores": self.stores_df,
            "products": self.products_df,
            "customers": self.customers_df,
            "transactions": self.transactions_df,
            "transaction_items": self.items_df,
        }

    def _generate_stores(self) -> pd.DataFrame:
        """Generate store data across 5 US regions."""
        stores = [
            {"store_id": 1,  "store_name": "Manhattan Flagship",      "store_code": "NYC-001", "store_type": "Flagship", "city": "New York",      "state": "New York",      "region": "Northeast", "square_footage": 45000, "manager_name": "Sarah Mitchell",  "opened_date": "2018-03-15"},
            {"store_id": 2,  "store_name": "Boston Harbor Square",    "store_code": "BOS-001", "store_type": "Standard", "city": "Boston",         "state": "Massachusetts","region": "Northeast", "square_footage": 22000, "manager_name": "James O'Brien",   "opened_date": "2019-06-01"},
            {"store_id": 3,  "store_name": "Atlanta Peachtree",       "store_code": "ATL-001", "store_type": "Standard", "city": "Atlanta",        "state": "Georgia",      "region": "Southeast", "square_footage": 25000, "manager_name": "Maria Rodriguez", "opened_date": "2019-09-20"},
            {"store_id": 4,  "store_name": "Miami Beach Outlet",      "store_code": "MIA-001", "store_type": "Outlet",   "city": "Miami Beach",    "state": "Florida",      "region": "Southeast", "square_footage": 18000, "manager_name": "David Chen",      "opened_date": "2020-01-10"},
            {"store_id": 5,  "store_name": "Chicago Michigan Ave",    "store_code": "CHI-001", "store_type": "Flagship", "city": "Chicago",        "state": "Illinois",     "region": "Midwest",   "square_footage": 40000, "manager_name": "Emily Watson",    "opened_date": "2017-11-25"},
            {"store_id": 6,  "store_name": "Minneapolis Mall",        "store_code": "MSP-001", "store_type": "Standard", "city": "Minneapolis",    "state": "Minnesota",    "region": "Midwest",   "square_footage": 20000, "manager_name": "Robert Kim",      "opened_date": "2021-04-15"},
            {"store_id": 7,  "store_name": "Dallas Galleria",         "store_code": "DAL-001", "store_type": "Standard", "city": "Dallas",         "state": "Texas",        "region": "Southwest", "square_footage": 28000, "manager_name": "Jessica Patel",   "opened_date": "2020-07-01"},
            {"store_id": 8,  "store_name": "Phoenix Express",         "store_code": "PHX-001", "store_type": "Express",  "city": "Phoenix",        "state": "Arizona",      "region": "Southwest", "square_footage": 12000, "manager_name": "Michael Torres",  "opened_date": "2022-02-28"},
            {"store_id": 9,  "store_name": "San Francisco Union Sq",  "store_code": "SFO-001", "store_type": "Flagship", "city": "San Francisco",  "state": "California",   "region": "West",      "square_footage": 38000, "manager_name": "Amanda Lee",      "opened_date": "2018-08-10"},
            {"store_id": 10, "store_name": "Seattle Pike Place",      "store_code": "SEA-001", "store_type": "Standard", "city": "Seattle",        "state": "Washington",   "region": "West",      "square_footage": 24000, "manager_name": "Chris Johnson",   "opened_date": "2019-12-01"},
        ]
        df = pd.DataFrame(stores)
        df["opened_date"] = pd.to_datetime(df["opened_date"])
        return df

    def _generate_products(self) -> pd.DataFrame:
        """Generate 120 products across 8 categories with realistic pricing."""
        products = []
        product_id = 1

        product_catalog = {
            "Electronics": [
                ("Ultra HD 65\" Smart TV", "Televisions", "TechVision", 1299.99, 780.00),
                ("Wireless Noise-Cancel Headphones", "Audio", "SoundWave", 349.99, 140.00),
                ("Bluetooth Portable Speaker", "Audio", "SoundWave", 89.99, 36.00),
                ("Laptop Pro 15\" i9", "Computers", "NexGen", 1899.99, 1140.00),
                ("Tablet Air 11\"", "Computers", "NexGen", 699.99, 350.00),
                ("Smart Watch Series X", "Wearables", "TechVision", 399.99, 160.00),
                ("Wireless Earbuds Pro", "Audio", "SoundWave", 199.99, 65.00),
                ("4K Action Camera", "Cameras", "CapturePro", 299.99, 135.00),
                ("Smart Home Hub", "Smart Home", "TechVision", 149.99, 60.00),
                ("Portable Power Bank 20000mAh", "Accessories", "ChargeMaster", 49.99, 18.00),
                ("Gaming Mouse RGB", "Accessories", "GameForce", 79.99, 28.00),
                ("Mechanical Keyboard", "Accessories", "GameForce", 159.99, 62.00),
                ("USB-C Docking Station", "Accessories", "NexGen", 129.99, 52.00),
                ("Wireless Charging Pad", "Accessories", "ChargeMaster", 34.99, 12.00),
                ("Smart Doorbell Camera", "Smart Home", "SecureView", 179.99, 72.00),
            ],
            "Clothing": [
                ("Premium Cotton T-Shirt", "Tops", "UrbanThread", 39.99, 12.00),
                ("Slim Fit Denim Jeans", "Bottoms", "DenimCraft", 79.99, 28.00),
                ("Classic Wool Blazer", "Outerwear", "FormalEdge", 249.99, 95.00),
                ("Running Performance Shorts", "Activewear", "AthleticPro", 44.99, 15.00),
                ("Merino Wool Sweater", "Tops", "WoolCo", 119.99, 48.00),
                ("Waterproof Winter Jacket", "Outerwear", "StormShield", 199.99, 80.00),
                ("Silk Formal Dress Shirt", "Tops", "FormalEdge", 89.99, 32.00),
                ("Yoga Leggings", "Activewear", "AthleticPro", 64.99, 22.00),
                ("Leather Belt Premium", "Accessories", "LeatherLux", 59.99, 18.00),
                ("Cashmere Scarf", "Accessories", "WoolCo", 89.99, 35.00),
                ("Tailored Chinos", "Bottoms", "UrbanThread", 69.99, 25.00),
                ("Athletic Hoodie", "Activewear", "AthleticPro", 74.99, 28.00),
                ("Linen Summer Dress", "Dresses", "UrbanThread", 99.99, 38.00),
                ("Fleece Zip Vest", "Outerwear", "StormShield", 84.99, 32.00),
                ("Performance Polo Shirt", "Tops", "AthleticPro", 54.99, 20.00),
            ],
            "Home & Garden": [
                ("Memory Foam Mattress Queen", "Bedroom", "SleepWell", 899.99, 360.00),
                ("Stainless Steel Cookware Set", "Kitchen", "ChefMaster", 299.99, 120.00),
                ("Smart LED Floor Lamp", "Lighting", "LuminaHome", 129.99, 48.00),
                ("Organic Cotton Sheet Set", "Bedroom", "SleepWell", 89.99, 32.00),
                ("Indoor Herb Garden Kit", "Garden", "GreenThumb", 59.99, 22.00),
                ("Ceramic Dining Set 16-Piece", "Kitchen", "ChefMaster", 149.99, 55.00),
                ("Velvet Throw Pillows Set 4", "Living Room", "DecorPlus", 69.99, 24.00),
                ("Air Purifier HEPA Large", "Living Room", "CleanAir", 249.99, 100.00),
                ("Bamboo Bathroom Shelving", "Bathroom", "NaturalHome", 79.99, 28.00),
                ("Espresso Machine Pro", "Kitchen", "BrewMaster", 599.99, 240.00),
                ("Smart Irrigation System", "Garden", "GreenThumb", 179.99, 72.00),
                ("Luxury Bath Towel Set", "Bathroom", "SleepWell", 54.99, 18.00),
                ("Cast Iron Dutch Oven", "Kitchen", "ChefMaster", 89.99, 36.00),
                ("Solar Garden Lights 10-Pack", "Garden", "EcoSmart", 44.99, 16.00),
                ("Weighted Blanket 15lb", "Bedroom", "SleepWell", 119.99, 45.00),
            ],
            "Sports & Fitness": [
                ("Adjustable Dumbbell Set", "Weights", "IronForge", 299.99, 120.00),
                ("Yoga Mat Premium 6mm", "Yoga", "FlexFit", 49.99, 15.00),
                ("Running Shoes UltraBoost", "Footwear", "SpeedStrike", 159.99, 60.00),
                ("Resistance Band Set Pro", "Accessories", "FlexFit", 34.99, 10.00),
                ("Foam Roller Recovery", "Recovery", "FlexFit", 29.99, 10.00),
                ("Cycling Helmet Aero", "Cycling", "SpeedStrike", 89.99, 35.00),
                ("Jump Rope Speed", "Accessories", "IronForge", 19.99, 6.00),
                ("Gym Bag Duffle XL", "Accessories", "AthleticPro", 59.99, 22.00),
                ("Protein Shaker Bottle", "Accessories", "FlexFit", 14.99, 4.00),
                ("Pull-Up Bar Doorway", "Equipment", "IronForge", 39.99, 14.00),
                ("Exercise Ball 65cm", "Yoga", "FlexFit", 24.99, 8.00),
                ("Trail Running Backpack", "Accessories", "SpeedStrike", 79.99, 30.00),
                ("Kettlebell Cast Iron 25lb", "Weights", "IronForge", 54.99, 20.00),
                ("Swimming Goggles Pro", "Swimming", "AquaSpeed", 29.99, 10.00),
                ("Fitness Tracker Band", "Wearables", "TechVision", 129.99, 48.00),
            ],
            "Beauty": [
                ("Anti-Aging Serum 30ml", "Skincare", "GlowLab", 89.99, 25.00),
                ("Hydrating Face Moisturizer", "Skincare", "GlowLab", 54.99, 18.00),
                ("Professional Hair Dryer", "Hair Care", "StylePro", 149.99, 55.00),
                ("Organic Shampoo & Conditioner", "Hair Care", "NaturalGlow", 29.99, 10.00),
                ("Luxury Perfume 100ml", "Fragrance", "EliteScent", 129.99, 40.00),
                ("SPF 50 Sunscreen Lotion", "Skincare", "GlowLab", 24.99, 8.00),
                ("Electric Toothbrush Smart", "Oral Care", "SmileTech", 99.99, 38.00),
                ("Nail Art Kit Professional", "Nail Care", "StylePro", 44.99, 15.00),
                ("Vitamin C Face Serum", "Skincare", "NaturalGlow", 39.99, 12.00),
                ("Beard Grooming Kit", "Grooming", "GentleMan", 49.99, 18.00),
                ("Eyeshadow Palette 24 Colors", "Makeup", "GlamStudio", 59.99, 20.00),
                ("Hair Straightener Ceramic", "Hair Care", "StylePro", 79.99, 30.00),
                ("Body Lotion Shea Butter", "Body Care", "NaturalGlow", 19.99, 6.00),
                ("Men's Cologne Classic", "Fragrance", "EliteScent", 89.99, 28.00),
                ("Lip Care Collection", "Makeup", "GlamStudio", 34.99, 12.00),
            ],
            "Books & Media": [
                ("Data Science Handbook", "Non-Fiction", "TechPress", 49.99, 15.00),
                ("SQL Mastery Guide", "Non-Fiction", "TechPress", 44.99, 14.00),
                ("Python Cookbook 4th Ed", "Non-Fiction", "TechPress", 54.99, 18.00),
                ("Leadership in Tech", "Non-Fiction", "BusinessBooks", 29.99, 10.00),
                ("Wireless Bluetooth Earbuds", "Audiobooks", "AudioWorld", 24.99, 8.00),
                ("Streaming Music Subscription", "Digital", "AudioWorld", 9.99, 3.00),
                ("Photography Masterclass DVD", "Education", "LearnPro", 39.99, 12.00),
                ("Bestseller Fiction Novel", "Fiction", "NovelHouse", 16.99, 5.00),
                ("Coding Interview Prep", "Non-Fiction", "TechPress", 39.99, 12.00),
                ("Art of Mindfulness", "Non-Fiction", "WellnessPress", 22.99, 7.00),
            ],
            "Food & Beverages": [
                ("Organic Coffee Beans 1kg", "Coffee & Tea", "BeanOrigin", 24.99, 9.00),
                ("Premium Green Tea Collection", "Coffee & Tea", "TeaHarvest", 18.99, 6.00),
                ("Artisan Dark Chocolate Box", "Confectionery", "CocoaCraft", 34.99, 12.00),
                ("Mixed Nuts Premium 500g", "Snacks", "NutHarvest", 14.99, 5.00),
                ("Extra Virgin Olive Oil 750ml", "Cooking", "MediterraneanGold", 19.99, 7.00),
                ("Protein Bar Variety Pack", "Health Food", "FitFuel", 29.99, 10.00),
                ("Sparkling Water 12-Pack", "Beverages", "CrystalSpring", 8.99, 3.00),
                ("Organic Honey Raw 500g", "Condiments", "NatureSweet", 16.99, 6.00),
                ("Gourmet Pasta Set", "Cooking", "ItalianTable", 22.99, 8.00),
                ("Cold Brew Coffee Concentrate", "Coffee & Tea", "BeanOrigin", 14.99, 5.00),
                ("Dried Fruit Mix Organic", "Snacks", "NutHarvest", 12.99, 4.00),
                ("Matcha Powder Ceremonial", "Coffee & Tea", "TeaHarvest", 29.99, 10.00),
                ("Hot Sauce Collection", "Condiments", "SpiceFire", 19.99, 7.00),
                ("Granola Clusters Crunchy", "Health Food", "FitFuel", 9.99, 3.00),
                ("Coconut Water 6-Pack", "Beverages", "TropicalPure", 11.99, 4.00),
            ],
            "Toys & Games": [
                ("STEM Building Blocks 500pc", "Educational", "BrainBuild", 49.99, 18.00),
                ("Remote Control Car Turbo", "Vehicles", "SpeedRacer", 79.99, 30.00),
                ("Strategy Board Game Deluxe", "Board Games", "GameNight", 44.99, 16.00),
                ("Art Supplies Mega Kit", "Arts & Crafts", "CreativeKids", 39.99, 14.00),
                ("Science Experiment Lab", "Educational", "BrainBuild", 59.99, 22.00),
                ("Plush Teddy Bear Giant", "Stuffed Animals", "CuddlePals", 29.99, 10.00),
                ("Puzzle 1000 Pieces World Map", "Puzzles", "PuzzleMaster", 24.99, 8.00),
                ("Action Figure Collection", "Action Figures", "HeroWorld", 34.99, 12.00),
                ("Building Blocks Castle Set", "Building Sets", "BrainBuild", 69.99, 25.00),
                ("Card Game Family Fun", "Card Games", "GameNight", 14.99, 5.00),
            ],
        }

        for category, items in product_catalog.items():
            for name, sub_cat, brand, price, cost in items:
                products.append({
                    "product_id": product_id,
                    "product_name": name,
                    "sku": f"{category[:4].upper()}-{product_id:03d}",
                    "category": category,
                    "sub_category": sub_cat,
                    "brand": brand,
                    "unit_price": price,
                    "unit_cost": cost,
                    "margin_pct": round((price - cost) / price * 100, 2),
                })
                product_id += 1

        return pd.DataFrame(products)

    def _generate_customers(self) -> pd.DataFrame:
        """Generate 200 customers with diverse demographics."""
        first_names_f = [
            "Emma", "Olivia", "Ava", "Sophia", "Isabella", "Mia", "Charlotte",
            "Amelia", "Harper", "Evelyn", "Abigail", "Emily", "Ella", "Grace",
            "Chloe", "Riley", "Zoey", "Penelope", "Layla", "Nora", "Lily",
            "Aria", "Eleanor", "Hannah", "Addison", "Aubrey", "Stella", "Savannah",
            "Victoria", "Violet", "Hazel", "Aurora", "Luna", "Willow", "Emilia",
            "Ivy", "Paisley", "Elena", "Naomi", "Clara", "Madeline", "Ellie",
            "Mackenzie", "Piper", "Bella", "Alice", "Ruby", "Madelyn", "Kennedy",
            "Sadie",
        ]
        first_names_m = [
            "Liam", "Noah", "James", "Benjamin", "Mason", "Ethan", "Alexander",
            "Daniel", "Michael", "William", "Lucas", "Henry", "Jack", "Sebastian",
            "Owen", "Aiden", "Matthew", "Jacob", "Logan", "Carter", "Jayden",
            "Dylan", "Luke", "Gabriel", "Isaac", "Caleb", "Thomas", "Samuel",
            "Joseph", "Levi", "Andrew", "Christopher", "Adrian", "Dominic", "Miles",
            "Charles", "Ezra", "Aaron", "Chase", "Hunter", "Eli", "Ryan",
            "Nathan", "Jason", "Zachary", "Adam", "Tyler", "Nicholas", "Ian",
            "Robert",
        ]
        last_names = [
            "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
            "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson",
            "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee",
            "Perez", "Thompson", "White", "Harris", "Sanchez", "Clark", "Ramirez",
            "Lewis", "Robinson", "Walker", "Young", "Allen", "King", "Wright",
            "Scott", "Torres", "Nguyen", "Hill", "Flores", "Green", "Adams",
            "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell", "Roberts",
            "Carter", "Phillips",
        ]
        cities_states = [
            ("New York", "New York"), ("Boston", "Massachusetts"),
            ("Atlanta", "Georgia"), ("Miami", "Florida"),
            ("Chicago", "Illinois"), ("Minneapolis", "Minnesota"),
            ("Dallas", "Texas"), ("Phoenix", "Arizona"),
            ("San Francisco", "California"), ("Seattle", "Washington"),
        ]

        customers = []
        for i in range(1, self.config["num_customers"] + 1):
            is_female = np.random.random() > 0.5
            first_name = np.random.choice(first_names_f if is_female else first_names_m)
            last_name = np.random.choice(last_names)
            city, state = cities_states[i % len(cities_states)]

            # Weighted loyalty tier distribution
            tier = np.random.choice(
                LOYALTY_TIERS,
                p=[0.40, 0.30, 0.20, 0.10]
            )

            join_date = pd.Timestamp("2023-01-01") + pd.Timedelta(
                days=int(np.random.uniform(0, 500))
            )

            customers.append({
                "customer_id": i,
                "first_name": first_name,
                "last_name": last_name,
                "email": f"{first_name.lower()}.{last_name.lower()}{i}@email.com",
                "gender": "Female" if is_female else "Male",
                "city": city,
                "state": state,
                "loyalty_tier": tier,
                "join_date": join_date,
                "is_active": True,
            })

        return pd.DataFrame(customers)

    def _generate_transactions(self) -> Tuple[pd.DataFrame, pd.DataFrame]:
        """Generate transactions with seasonal patterns and realistic line items."""
        transactions = []
        items = []
        txn_id = 1
        item_id = 1

        start_date = pd.Timestamp(self.config["date_range_start"])
        end_date = pd.Timestamp(self.config["date_range_end"])
        tax_rate = 0.0825

        num_customers = len(self.customers_df)
        num_products = len(self.products_df)
        num_stores = len(self.stores_df)

        # Generate transactions month by month
        current_date = start_date
        while current_date <= end_date:
            year = current_date.year
            month = current_date.month

            # Base volume with seasonal adjustment
            base = self.config["base_monthly_transactions"]
            seasonal = self.config["seasonal_multipliers"].get(month, 1.0)
            yoy_factor = 1 + self.config["yoy_growth_rate"] if year > 2024 else 1.0

            target_txns = int(base * seasonal * yoy_factor)
            # Add noise ±15%
            target_txns = max(40, int(target_txns * (1 + np.random.uniform(-0.15, 0.15))))

            for _ in range(target_txns):
                # Random date within the month
                day = min(np.random.randint(1, 29), 28)
                hour = np.random.randint(8, 22)
                minute = np.random.randint(0, 60)
                txn_date = pd.Timestamp(year=year, month=month, day=day, hour=hour, minute=minute)

                customer_id = np.random.randint(1, num_customers + 1)
                store_id = np.random.randint(1, num_stores + 1)
                payment = np.random.choice(PAYMENT_METHODS, p=[0.35, 0.25, 0.15, 0.15, 0.05, 0.05])

                # Order status: 95% completed
                status_roll = np.random.random()
                if status_roll < 0.95:
                    status = "Completed"
                elif status_roll < 0.97:
                    status = "Returned"
                elif status_roll < 0.99:
                    status = "Cancelled"
                else:
                    status = "Refunded"

                # Items per transaction (1-6, weighted toward 2-3)
                num_items = max(1, min(6, int(np.random.normal(2.5, 1.0))))

                subtotal = 0.0
                txn_items = []

                for _ in range(num_items):
                    prod_id = np.random.randint(1, num_products + 1)
                    product = self.products_df[self.products_df["product_id"] == prod_id].iloc[0]
                    quantity = max(1, min(5, int(np.random.exponential(1.5) + 1)))
                    unit_price = product["unit_price"]

                    # Discount: 70% no discount, 20% gets 5-15%, 10% gets 20-30%
                    discount_roll = np.random.random()
                    if discount_roll < 0.70:
                        discount_pct = 0.0
                    elif discount_roll < 0.90:
                        discount_pct = round(np.random.uniform(5, 15), 2)
                    else:
                        discount_pct = round(np.random.uniform(20, 30), 2)

                    line_total = round(quantity * unit_price * (1 - discount_pct / 100), 2)
                    subtotal += line_total

                    txn_items.append({
                        "item_id": item_id,
                        "transaction_id": txn_id,
                        "product_id": prod_id,
                        "quantity": quantity,
                        "unit_price": unit_price,
                        "discount_pct": discount_pct,
                        "line_total": line_total,
                    })
                    item_id += 1

                # Order-level discount (15% of orders get 2-5% extra discount)
                order_discount = round(subtotal * np.random.uniform(0.02, 0.05), 2) if np.random.random() < 0.15 else 0.0
                tax_amount = round((subtotal - order_discount) * tax_rate, 2)
                total_amount = round(subtotal - order_discount + tax_amount, 2)

                transactions.append({
                    "transaction_id": txn_id,
                    "transaction_date": txn_date,
                    "customer_id": customer_id,
                    "store_id": store_id,
                    "payment_method": payment,
                    "subtotal": round(subtotal, 2),
                    "discount_amount": order_discount,
                    "tax_amount": tax_amount,
                    "total_amount": total_amount,
                    "order_status": status,
                })
                items.extend(txn_items)
                txn_id += 1

            # Move to next month
            if month == 12:
                current_date = pd.Timestamp(year=year + 1, month=1, day=1)
            else:
                current_date = pd.Timestamp(year=year, month=month + 1, day=1)

        transactions_df = pd.DataFrame(transactions)
        items_df = pd.DataFrame(items)

        return transactions_df, items_df


def generate_data() -> Dict[str, pd.DataFrame]:
    """Convenience function to generate all data."""
    generator = RetailDataGenerator()
    return generator.generate_all()


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    data = generate_data()
    for name, df in data.items():
        print(f"\n📊 {name}: {len(df)} rows, {len(df.columns)} columns")
        print(df.head(3).to_string(index=False))
