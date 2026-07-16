-- ============================================================================
-- RETAIL SALES ANALYTICS — SEED DATA
-- Realistic sample data for analytics demonstration
-- ============================================================================
-- 200+ Customers | 100+ Products | 10 Stores | 2000+ Transactions | 5000+ Items
-- Data spans January 2024 — December 2025 with seasonal patterns
-- ============================================================================

SET search_path TO retail_analytics;

-- ============================================================================
-- STORES (10 stores across 5 regions)
-- ============================================================================
INSERT INTO stores (store_name, store_code, store_type, address, city, state, region, zip_code, phone, manager_name, square_footage, opened_date) VALUES
('Manhattan Flagship',      'NYC-001', 'Flagship',  '350 Fifth Avenue',           'New York',      'New York',      'Northeast', '10118', '212-555-0101', 'Sarah Mitchell',   45000, '2018-03-15'),
('Boston Harbor Square',    'BOS-001', 'Standard',  '100 Harborside Drive',       'Boston',         'Massachusetts', 'Northeast', '02210', '617-555-0102', 'James O''Brien',   22000, '2019-06-01'),
('Atlanta Peachtree',       'ATL-001', 'Standard',  '200 Peachtree Street NW',    'Atlanta',        'Georgia',       'Southeast', '30303', '404-555-0103', 'Maria Rodriguez',  25000, '2019-09-20'),
('Miami Beach Outlet',      'MIA-001', 'Outlet',    '1600 Collins Avenue',        'Miami Beach',    'Florida',       'Southeast', '33139', '305-555-0104', 'David Chen',       18000, '2020-01-10'),
('Chicago Michigan Ave',    'CHI-001', 'Flagship',  '900 N Michigan Avenue',      'Chicago',        'Illinois',      'Midwest',   '60611', '312-555-0105', 'Emily Watson',     40000, '2017-11-25'),
('Minneapolis Mall',        'MSP-001', 'Standard',  '60 E Broadway',              'Minneapolis',    'Minnesota',     'Midwest',   '55425', '952-555-0106', 'Robert Kim',       20000, '2021-04-15'),
('Dallas Galleria',         'DAL-001', 'Standard',  '13350 Dallas Parkway',       'Dallas',         'Texas',         'Southwest', '75240', '972-555-0107', 'Jessica Patel',    28000, '2020-07-01'),
('Phoenix Express',         'PHX-001', 'Express',   '2502 E Camelback Road',      'Phoenix',        'Arizona',       'Southwest', '85016', '602-555-0108', 'Michael Torres',   12000, '2022-02-28'),
('San Francisco Union Sq',  'SFO-001', 'Flagship',  '333 Post Street',            'San Francisco',  'California',    'West',      '94108', '415-555-0109', 'Amanda Lee',       38000, '2018-08-10'),
('Seattle Pike Place',      'SEA-001', 'Standard',  '1501 Pike Place',            'Seattle',        'Washington',    'West',      '98101', '206-555-0110', 'Chris Johnson',    24000, '2019-12-01');

-- ============================================================================
-- PRODUCTS (120 products across 8 categories)
-- ============================================================================
INSERT INTO products (product_name, sku, category, sub_category, brand, unit_price, unit_cost, weight_kg, launch_date) VALUES
-- ELECTRONICS (20 products)
('Ultra HD 65" Smart TV',           'ELEC-TV-001',   'Electronics',  'Televisions',       'TechVision',     1299.99,  780.00,  22.500, '2024-01-15'),
('Wireless Noise-Cancel Headphones','ELEC-HP-001',   'Electronics',  'Audio',             'SoundWave',       349.99,  140.00,   0.320, '2024-02-01'),
('Bluetooth Portable Speaker',      'ELEC-SP-001',   'Electronics',  'Audio',             'SoundWave',        89.99,   36.00,   0.680, '2024-01-10'),
('Laptop Pro 15" i9',               'ELEC-LP-001',   'Electronics',  'Computers',         'NexGen',         1899.99, 1140.00,   1.850, '2024-03-01'),
('Tablet Air 11"',                  'ELEC-TB-001',   'Electronics',  'Computers',         'NexGen',          699.99,  350.00,   0.460, '2024-01-20'),
('Smart Watch Series X',            'ELEC-SW-001',   'Electronics',  'Wearables',         'TechVision',      399.99,  160.00,   0.045, '2024-04-15'),
('Wireless Earbuds Pro',            'ELEC-EB-001',   'Electronics',  'Audio',             'SoundWave',       199.99,   65.00,   0.055, '2024-02-10'),
('4K Action Camera',                'ELEC-AC-001',   'Electronics',  'Cameras',           'CapturePro',      299.99,  135.00,   0.125, '2024-05-01'),
('Smart Home Hub',                  'ELEC-HB-001',   'Electronics',  'Smart Home',        'TechVision',      149.99,   60.00,   0.380, '2024-01-05'),
('Portable Power Bank 20000mAh',    'ELEC-PB-001',   'Electronics',  'Accessories',       'ChargeMaster',     49.99,   18.00,   0.450, '2024-03-20'),
('Gaming Mouse RGB',                'ELEC-GM-001',   'Electronics',  'Accessories',       'GameForce',        79.99,   28.00,   0.095, '2024-06-01'),
('Mechanical Keyboard',             'ELEC-KB-001',   'Electronics',  'Accessories',       'GameForce',       159.99,   62.00,   0.920, '2024-04-10'),
('USB-C Docking Station',           'ELEC-DS-001',   'Electronics',  'Accessories',       'NexGen',          129.99,   52.00,   0.340, '2024-02-15'),
('Wireless Charging Pad',           'ELEC-WC-001',   'Electronics',  'Accessories',       'ChargeMaster',     34.99,   12.00,   0.180, '2024-01-25'),
('Smart Doorbell Camera',           'ELEC-DC-001',   'Electronics',  'Smart Home',        'SecureView',      179.99,   72.00,   0.280, '2024-05-15'),
('Robot Vacuum Pro',                'ELEC-RV-001',   'Electronics',  'Smart Home',        'CleanBot',        549.99,  220.00,   3.600, '2024-03-10'),
('E-Reader Paperlight',             'ELEC-ER-001',   'Electronics',  'Computers',         'ReadWell',        139.99,   56.00,   0.180, '2024-07-01'),
('Drone Explorer 4K',               'ELEC-DR-001',   'Electronics',  'Cameras',           'SkyTech',         799.99,  360.00,   0.750, '2024-06-15'),
('Smart Thermostat',                'ELEC-ST-001',   'Electronics',  'Smart Home',        'EcoSmart',        249.99,  100.00,   0.210, '2024-04-20'),
('Portable Projector Mini',         'ELEC-PJ-001',   'Electronics',  'Computers',         'CapturePro',      449.99,  180.00,   0.950, '2024-08-01'),

-- CLOTHING (20 products)
('Premium Cotton T-Shirt',          'CLTH-TS-001',   'Clothing',     'Tops',              'UrbanThread',      39.99,   12.00,   0.200, '2024-01-01'),
('Slim Fit Denim Jeans',            'CLTH-JN-001',   'Clothing',     'Bottoms',           'DenimCraft',       79.99,   28.00,   0.600, '2024-01-01'),
('Classic Wool Blazer',             'CLTH-BZ-001',   'Clothing',     'Outerwear',         'FormalEdge',      249.99,   95.00,   0.900, '2024-02-15'),
('Running Performance Shorts',      'CLTH-SH-001',   'Clothing',     'Activewear',        'AthleticPro',      44.99,   15.00,   0.150, '2024-03-01'),
('Merino Wool Sweater',             'CLTH-SW-001',   'Clothing',     'Tops',              'WoolCo',          119.99,   48.00,   0.400, '2024-09-01'),
('Waterproof Winter Jacket',        'CLTH-WJ-001',   'Clothing',     'Outerwear',         'StormShield',     199.99,   80.00,   1.200, '2024-10-01'),
('Silk Formal Dress Shirt',         'CLTH-DS-001',   'Clothing',     'Tops',              'FormalEdge',       89.99,   32.00,   0.250, '2024-01-15'),
('Yoga Leggings',                   'CLTH-YL-001',   'Clothing',     'Activewear',        'AthleticPro',      64.99,   22.00,   0.180, '2024-02-01'),
('Leather Belt Premium',            'CLTH-LB-001',   'Clothing',     'Accessories',       'LeatherLux',       59.99,   18.00,   0.280, '2024-01-01'),
('Cashmere Scarf',                  'CLTH-CS-001',   'Clothing',     'Accessories',       'WoolCo',           89.99,   35.00,   0.120, '2024-10-15'),
('Tailored Chinos',                 'CLTH-CH-001',   'Clothing',     'Bottoms',           'UrbanThread',      69.99,   25.00,   0.450, '2024-03-01'),
('Athletic Hoodie',                 'CLTH-AH-001',   'Clothing',     'Activewear',        'AthleticPro',      74.99,   28.00,   0.550, '2024-04-01'),
('Linen Summer Dress',              'CLTH-SD-001',   'Clothing',     'Dresses',           'UrbanThread',      99.99,   38.00,   0.300, '2024-05-01'),
('Fleece Zip Vest',                 'CLTH-FV-001',   'Clothing',     'Outerwear',         'StormShield',      84.99,   32.00,   0.380, '2024-09-15'),
('Performance Polo Shirt',          'CLTH-PP-001',   'Clothing',     'Tops',              'AthleticPro',      54.99,   20.00,   0.220, '2024-04-15'),
('Corduroy Trousers',               'CLTH-CT-001',   'Clothing',     'Bottoms',           'DenimCraft',       89.99,   34.00,   0.520, '2024-08-01'),
('Rain Poncho Compact',             'CLTH-RP-001',   'Clothing',     'Outerwear',         'StormShield',      34.99,   12.00,   0.200, '2024-06-01'),
('Graphic Print Sweatshirt',        'CLTH-GS-001',   'Clothing',     'Tops',              'UrbanThread',      59.99,   22.00,   0.480, '2024-01-20'),
('Thermal Base Layer Set',          'CLTH-TH-001',   'Clothing',     'Activewear',        'AthleticPro',      79.99,   30.00,   0.350, '2024-11-01'),
('Weekend Travel Blazer',           'CLTH-TB-001',   'Clothing',     'Outerwear',         'FormalEdge',      179.99,   70.00,   0.750, '2024-02-28'),

-- HOME & GARDEN (15 products)
('Memory Foam Mattress Queen',      'HOME-MF-001',   'Home & Garden','Bedroom',           'SleepWell',       899.99,  360.00,  28.000, '2024-01-01'),
('Stainless Steel Cookware Set',    'HOME-CK-001',   'Home & Garden','Kitchen',           'ChefMaster',      299.99,  120.00,   8.500, '2024-02-01'),
('Smart LED Floor Lamp',            'HOME-FL-001',   'Home & Garden','Lighting',          'LuminaHome',      129.99,   48.00,   3.200, '2024-03-01'),
('Organic Cotton Sheet Set',        'HOME-SS-001',   'Home & Garden','Bedroom',           'SleepWell',        89.99,   32.00,   1.800, '2024-01-15'),
('Indoor Herb Garden Kit',          'HOME-HG-001',   'Home & Garden','Garden',            'GreenThumb',       59.99,   22.00,   2.400, '2024-04-01'),
('Ceramic Dining Set 16-Piece',     'HOME-DS-001',   'Home & Garden','Kitchen',           'ChefMaster',      149.99,   55.00,   9.500, '2024-01-01'),
('Velvet Throw Pillows (Set 4)',    'HOME-TP-001',   'Home & Garden','Living Room',       'DecorPlus',        69.99,   24.00,   1.600, '2024-05-01'),
('Air Purifier HEPA Large',         'HOME-AP-001',   'Home & Garden','Living Room',       'CleanAir',        249.99,  100.00,   5.400, '2024-02-15'),
('Bamboo Bathroom Shelving',        'HOME-BS-001',   'Home & Garden','Bathroom',          'NaturalHome',      79.99,   28.00,   4.200, '2024-06-01'),
('Espresso Machine Pro',            'HOME-EM-001',   'Home & Garden','Kitchen',           'BrewMaster',      599.99,  240.00,   7.800, '2024-03-15'),
('Smart Irrigation System',         'HOME-IS-001',   'Home & Garden','Garden',            'GreenThumb',      179.99,   72.00,   1.900, '2024-04-15'),
('Luxury Bath Towel Set',           'HOME-BT-001',   'Home & Garden','Bathroom',          'SleepWell',        54.99,   18.00,   2.200, '2024-01-01'),
('Cast Iron Dutch Oven',            'HOME-DO-001',   'Home & Garden','Kitchen',           'ChefMaster',       89.99,   36.00,   5.800, '2024-07-01'),
('Solar Garden Lights (10-Pack)',   'HOME-GL-001',   'Home & Garden','Garden',            'EcoSmart',         44.99,   16.00,   1.200, '2024-05-15'),
('Weighted Blanket 15lb',           'HOME-WB-001',   'Home & Garden','Bedroom',           'SleepWell',       119.99,   45.00,   6.800, '2024-08-01'),

-- SPORTS & FITNESS (15 products)
('Adjustable Dumbbell Set',         'SPRT-DB-001',   'Sports & Fitness','Weights',        'IronForge',       299.99,  120.00,  24.000, '2024-01-01'),
('Yoga Mat Premium 6mm',            'SPRT-YM-001',   'Sports & Fitness','Yoga',           'FlexFit',          49.99,   15.00,   1.500, '2024-01-15'),
('Running Shoes UltraBoost',        'SPRT-RS-001',   'Sports & Fitness','Footwear',       'SpeedStrike',     159.99,   60.00,   0.620, '2024-02-01'),
('Resistance Band Set Pro',         'SPRT-RB-001',   'Sports & Fitness','Accessories',    'FlexFit',          34.99,   10.00,   0.450, '2024-01-01'),
('Foam Roller Recovery',            'SPRT-FR-001',   'Sports & Fitness','Recovery',       'FlexFit',          29.99,   10.00,   0.800, '2024-03-01'),
('Cycling Helmet Aero',             'SPRT-CH-001',   'Sports & Fitness','Cycling',        'SpeedStrike',      89.99,   35.00,   0.280, '2024-04-01'),
('Jump Rope Speed',                 'SPRT-JR-001',   'Sports & Fitness','Accessories',    'IronForge',        19.99,    6.00,   0.200, '2024-01-01'),
('Gym Bag Duffle XL',               'SPRT-GB-001',   'Sports & Fitness','Accessories',    'AthleticPro',      59.99,   22.00,   0.900, '2024-02-15'),
('Protein Shaker Bottle',           'SPRT-SB-001',   'Sports & Fitness','Accessories',    'FlexFit',          14.99,    4.00,   0.150, '2024-01-01'),
('Pull-Up Bar Doorway',             'SPRT-PU-001',   'Sports & Fitness','Equipment',      'IronForge',        39.99,   14.00,   2.800, '2024-05-01'),
('Exercise Ball 65cm',              'SPRT-EB-001',   'Sports & Fitness','Yoga',           'FlexFit',          24.99,    8.00,   1.100, '2024-01-20'),
('Trail Running Backpack',          'SPRT-TB-001',   'Sports & Fitness','Accessories',    'SpeedStrike',      79.99,   30.00,   0.450, '2024-06-01'),
('Kettlebell Cast Iron 25lb',       'SPRT-KB-001',   'Sports & Fitness','Weights',        'IronForge',        54.99,   20.00,  11.300, '2024-01-01'),
('Swimming Goggles Pro',            'SPRT-SG-001',   'Sports & Fitness','Swimming',       'AquaSpeed',        29.99,   10.00,   0.080, '2024-03-15'),
('Fitness Tracker Band',            'SPRT-FT-001',   'Sports & Fitness','Wearables',      'TechVision',      129.99,   48.00,   0.035, '2024-04-01'),

-- BEAUTY & PERSONAL CARE (15 products)
('Anti-Aging Serum 30ml',           'BEAU-AS-001',   'Beauty',       'Skincare',          'GlowLab',          89.99,   25.00,   0.065, '2024-01-01'),
('Hydrating Face Moisturizer',      'BEAU-FM-001',   'Beauty',       'Skincare',          'GlowLab',          54.99,   18.00,   0.120, '2024-01-15'),
('Professional Hair Dryer',         'BEAU-HD-001',   'Beauty',       'Hair Care',         'StylePro',        149.99,   55.00,   0.680, '2024-02-01'),
('Organic Shampoo & Conditioner',   'BEAU-SC-001',   'Beauty',       'Hair Care',         'NaturalGlow',      29.99,   10.00,   0.750, '2024-01-01'),
('Luxury Perfume 100ml',            'BEAU-PF-001',   'Beauty',       'Fragrance',         'EliteScent',      129.99,   40.00,   0.250, '2024-03-01'),
('SPF 50 Sunscreen Lotion',         'BEAU-SS-001',   'Beauty',       'Skincare',          'GlowLab',          24.99,    8.00,   0.200, '2024-04-01'),
('Electric Toothbrush Smart',       'BEAU-ET-001',   'Beauty',       'Oral Care',         'SmileTech',        99.99,   38.00,   0.220, '2024-01-01'),
('Nail Art Kit Professional',       'BEAU-NK-001',   'Beauty',       'Nail Care',         'StylePro',         44.99,   15.00,   0.350, '2024-05-01'),
('Vitamin C Face Serum',            'BEAU-VC-001',   'Beauty',       'Skincare',          'NaturalGlow',      39.99,   12.00,   0.060, '2024-02-15'),
('Beard Grooming Kit',              'BEAU-BG-001',   'Beauty',       'Grooming',          'GentleMan',        49.99,   18.00,   0.400, '2024-01-01'),
('Eyeshadow Palette 24 Colors',    'BEAU-EP-001',   'Beauty',       'Makeup',            'GlamStudio',       59.99,   20.00,   0.180, '2024-06-01'),
('Hair Straightener Ceramic',       'BEAU-HS-001',   'Beauty',       'Hair Care',         'StylePro',         79.99,   30.00,   0.420, '2024-03-15'),
('Body Lotion Shea Butter',         'BEAU-BL-001',   'Beauty',       'Body Care',         'NaturalGlow',      19.99,    6.00,   0.350, '2024-01-01'),
('Men''s Cologne Classic',          'BEAU-MC-001',   'Beauty',       'Fragrance',         'EliteScent',       89.99,   28.00,   0.220, '2024-04-15'),
('Lip Care Collection',             'BEAU-LC-001',   'Beauty',       'Makeup',            'GlamStudio',       34.99,   12.00,   0.095, '2024-07-01'),

-- BOOKS & MEDIA (10 products)
('Data Science Handbook',           'BOOK-DS-001',   'Books & Media','Non-Fiction',       'TechPress',        49.99,   15.00,   0.800, '2024-01-01'),
('SQL Mastery Guide',               'BOOK-SQ-001',   'Books & Media','Non-Fiction',       'TechPress',        44.99,   14.00,   0.720, '2024-02-01'),
('Python Cookbook 4th Ed',           'BOOK-PY-001',   'Books & Media','Non-Fiction',       'TechPress',        54.99,   18.00,   0.950, '2024-01-15'),
('Leadership in Tech',              'BOOK-LT-001',   'Books & Media','Non-Fiction',       'BusinessBooks',    29.99,   10.00,   0.400, '2024-03-01'),
('Wireless Bluetooth Earbuds',      'BOOK-WE-001',   'Books & Media','Audiobooks',        'AudioWorld',       24.99,    8.00,   0.060, '2024-01-01'),
('Streaming Music Subscription',    'BOOK-SM-001',   'Books & Media','Digital',           'AudioWorld',        9.99,    3.00,   0.000, '2024-01-01'),
('Photography Masterclass DVD',     'BOOK-PM-001',   'Books & Media','Education',         'LearnPro',         39.99,   12.00,   0.100, '2024-04-01'),
('Bestseller Fiction Novel',        'BOOK-BF-001',   'Books & Media','Fiction',           'NovelHouse',       16.99,    5.00,   0.320, '2024-05-01'),
('Coding Interview Prep',           'BOOK-CI-001',   'Books & Media','Non-Fiction',       'TechPress',        39.99,   12.00,   0.680, '2024-02-15'),
('Art of Mindfulness',              'BOOK-AM-001',   'Books & Media','Non-Fiction',       'WellnessPress',    22.99,    7.00,   0.350, '2024-06-01'),

-- FOOD & BEVERAGES (15 products)
('Organic Coffee Beans 1kg',        'FOOD-CB-001',   'Food & Beverages','Coffee & Tea',   'BeanOrigin',       24.99,    9.00,   1.000, '2024-01-01'),
('Premium Green Tea Collection',    'FOOD-GT-001',   'Food & Beverages','Coffee & Tea',   'TeaHarvest',       18.99,    6.00,   0.250, '2024-01-15'),
('Artisan Dark Chocolate Box',      'FOOD-DC-001',   'Food & Beverages','Confectionery',  'CocoaCraft',       34.99,   12.00,   0.500, '2024-02-01'),
('Mixed Nuts Premium 500g',         'FOOD-MN-001',   'Food & Beverages','Snacks',         'NutHarvest',       14.99,    5.00,   0.500, '2024-01-01'),
('Extra Virgin Olive Oil 750ml',    'FOOD-OO-001',   'Food & Beverages','Cooking',        'MediterraneanGold', 19.99,   7.00,   0.950, '2024-03-01'),
('Protein Bar Variety Pack',        'FOOD-PB-001',   'Food & Beverages','Health Food',    'FitFuel',          29.99,   10.00,   0.600, '2024-01-01'),
('Sparkling Water 12-Pack',         'FOOD-SW-001',   'Food & Beverages','Beverages',      'CrystalSpring',     8.99,    3.00,   4.500, '2024-01-01'),
('Organic Honey Raw 500g',          'FOOD-OH-001',   'Food & Beverages','Condiments',     'NatureSweet',      16.99,    6.00,   0.550, '2024-04-01'),
('Gourmet Pasta Set',               'FOOD-GP-001',   'Food & Beverages','Cooking',        'ItalianTable',     22.99,    8.00,   1.200, '2024-02-15'),
('Cold Brew Coffee Concentrate',    'FOOD-CC-001',   'Food & Beverages','Coffee & Tea',   'BeanOrigin',       14.99,    5.00,   0.750, '2024-05-01'),
('Dried Fruit Mix Organic',         'FOOD-DF-001',   'Food & Beverages','Snacks',         'NutHarvest',       12.99,    4.00,   0.400, '2024-01-01'),
('Matcha Powder Ceremonial',        'FOOD-MP-001',   'Food & Beverages','Coffee & Tea',   'TeaHarvest',       29.99,   10.00,   0.100, '2024-06-01'),
('Hot Sauce Collection',            'FOOD-HS-001',   'Food & Beverages','Condiments',     'SpiceFire',        19.99,    7.00,   0.800, '2024-03-15'),
('Granola Clusters Crunchy',        'FOOD-GC-001',   'Food & Beverages','Health Food',    'FitFuel',           9.99,    3.00,   0.450, '2024-01-01'),
('Coconut Water 6-Pack',            'FOOD-CW-001',   'Food & Beverages','Beverages',      'TropicalPure',     11.99,    4.00,   2.400, '2024-07-01'),

-- TOYS & GAMES (10 products)
('STEM Building Blocks 500pc',      'TOYS-BB-001',   'Toys & Games','Educational',        'BrainBuild',       49.99,   18.00,   1.200, '2024-01-01'),
('Remote Control Car Turbo',        'TOYS-RC-001',   'Toys & Games','Vehicles',           'SpeedRacer',       79.99,   30.00,   1.500, '2024-02-01'),
('Strategy Board Game Deluxe',      'TOYS-BG-001',   'Toys & Games','Board Games',        'GameNight',        44.99,   16.00,   1.800, '2024-01-15'),
('Art Supplies Mega Kit',           'TOYS-AS-001',   'Toys & Games','Arts & Crafts',      'CreativeKids',     39.99,   14.00,   2.200, '2024-03-01'),
('Science Experiment Lab',          'TOYS-SE-001',   'Toys & Games','Educational',        'BrainBuild',       59.99,   22.00,   1.400, '2024-04-01'),
('Plush Teddy Bear Giant',          'TOYS-PB-001',   'Toys & Games','Stuffed Animals',    'CuddlePals',       29.99,   10.00,   0.800, '2024-01-01'),
('Puzzle 1000 Pieces World Map',    'TOYS-PZ-001',   'Toys & Games','Puzzles',            'PuzzleMaster',     24.99,    8.00,   0.600, '2024-05-01'),
('Action Figure Collection',        'TOYS-AF-001',   'Toys & Games','Action Figures',     'HeroWorld',        34.99,   12.00,   0.350, '2024-02-15'),
('Building Blocks Castle Set',      'TOYS-BC-001',   'Toys & Games','Building Sets',      'BrainBuild',       69.99,   25.00,   1.600, '2024-06-01'),
('Card Game Family Fun',            'TOYS-CG-001',   'Toys & Games','Card Games',         'GameNight',        14.99,    5.00,   0.200, '2024-01-01');

-- ============================================================================
-- CUSTOMERS (200 customers)
-- Generated with diverse demographics across US cities
-- ============================================================================
INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, gender, city, state, zip_code, loyalty_tier, join_date) VALUES
('Emma',      'Johnson',    'emma.johnson@email.com',       '212-555-1001', '1990-03-15', 'Female',   'New York',       'New York',         '10001', 'Platinum', '2023-01-15'),
('Liam',      'Williams',   'liam.williams@email.com',      '212-555-1002', '1985-07-22', 'Male',     'New York',       'New York',         '10002', 'Gold',     '2023-02-20'),
('Olivia',    'Brown',      'olivia.brown@email.com',       '617-555-1003', '1992-11-08', 'Female',   'Boston',          'Massachusetts',   '02210', 'Silver',   '2023-03-10'),
('Noah',      'Jones',      'noah.jones@email.com',         '617-555-1004', '1988-05-30', 'Male',     'Boston',          'Massachusetts',   '02215', 'Gold',     '2023-01-25'),
('Ava',       'Garcia',     'ava.garcia@email.com',         '404-555-1005', '1995-09-12', 'Female',   'Atlanta',         'Georgia',         '30301', 'Bronze',   '2023-04-05'),
('James',     'Miller',     'james.miller@email.com',       '404-555-1006', '1982-12-03', 'Male',     'Atlanta',         'Georgia',         '30305', 'Silver',   '2023-02-14'),
('Sophia',    'Davis',      'sophia.davis@email.com',       '305-555-1007', '1993-06-18', 'Female',   'Miami',           'Florida',         '33101', 'Gold',     '2023-05-01'),
('Benjamin',  'Rodriguez',  'benjamin.rodriguez@email.com', '305-555-1008', '1991-01-25', 'Male',     'Miami',           'Florida',         '33139', 'Bronze',   '2023-03-20'),
('Isabella',  'Martinez',   'isabella.martinez@email.com',  '312-555-1009', '1987-08-14', 'Female',   'Chicago',         'Illinois',        '60601', 'Platinum', '2023-01-05'),
('Mason',     'Hernandez',  'mason.hernandez@email.com',    '312-555-1010', '1994-04-07', 'Male',     'Chicago',         'Illinois',        '60611', 'Silver',   '2023-06-15'),
('Mia',       'Lopez',      'mia.lopez@email.com',          '952-555-1011', '1996-02-28', 'Female',   'Minneapolis',     'Minnesota',       '55401', 'Bronze',   '2023-04-22'),
('Ethan',     'Gonzalez',   'ethan.gonzalez@email.com',     '952-555-1012', '1989-10-19', 'Male',     'Minneapolis',     'Minnesota',       '55425', 'Gold',     '2023-02-08'),
('Charlotte', 'Wilson',     'charlotte.wilson@email.com',   '972-555-1013', '1990-07-11', 'Female',   'Dallas',          'Texas',           '75201', 'Silver',   '2023-07-01'),
('Alexander', 'Anderson',   'alexander.anderson@email.com', '972-555-1014', '1986-03-26', 'Male',     'Dallas',          'Texas',           '75240', 'Platinum', '2023-01-12'),
('Amelia',    'Thomas',     'amelia.thomas@email.com',      '602-555-1015', '1997-12-05', 'Female',   'Phoenix',         'Arizona',         '85001', 'Bronze',   '2023-05-18'),
('Daniel',    'Taylor',     'daniel.taylor@email.com',      '602-555-1016', '1984-09-30', 'Male',     'Phoenix',         'Arizona',         '85016', 'Silver',   '2023-03-30'),
('Harper',    'Moore',      'harper.moore@email.com',       '415-555-1017', '1991-06-22', 'Female',   'San Francisco',   'California',      '94102', 'Gold',     '2023-08-05'),
('Michael',   'Jackson',    'michael.jackson2@email.com',   '415-555-1018', '1983-11-15', 'Male',     'San Francisco',   'California',      '94108', 'Platinum', '2023-01-20'),
('Evelyn',    'Martin',     'evelyn.martin@email.com',      '206-555-1019', '1994-08-09', 'Female',   'Seattle',         'Washington',      '98101', 'Bronze',   '2023-06-28'),
('William',   'Lee',        'william.lee@email.com',        '206-555-1020', '1988-02-14', 'Male',     'Seattle',         'Washington',      '98105', 'Gold',     '2023-02-01'),
('Abigail',   'Perez',      'abigail.perez@email.com',     '212-555-1021', '1993-04-17', 'Female',   'New York',       'New York',         '10003', 'Silver',   '2023-09-10'),
('Lucas',     'Thompson',   'lucas.thompson@email.com',     '617-555-1022', '1990-10-03', 'Male',     'Boston',          'Massachusetts',   '02116', 'Bronze',   '2023-04-15'),
('Emily',     'White',      'emily.white@email.com',        '404-555-1023', '1986-01-20', 'Female',   'Atlanta',         'Georgia',         '30308', 'Gold',     '2023-10-01'),
('Henry',     'Harris',     'henry.harris@email.com',       '305-555-1024', '1992-07-05', 'Male',     'Miami',           'Florida',         '33125', 'Silver',   '2023-03-05'),
('Ella',      'Sanchez',    'ella.sanchez@email.com',       '312-555-1025', '1995-11-28', 'Female',   'Chicago',         'Illinois',        '60614', 'Platinum', '2023-01-30'),
('Jack',      'Clark',      'jack.clark@email.com',         '952-555-1026', '1987-05-16', 'Male',     'Minneapolis',     'Minnesota',       '55402', 'Bronze',   '2023-05-25'),
('Grace',     'Ramirez',    'grace.ramirez@email.com',      '972-555-1027', '1998-03-09', 'Female',   'Dallas',          'Texas',           '75202', 'Silver',   '2023-11-12'),
('Sebastian', 'Lewis',      'sebastian.lewis@email.com',    '602-555-1028', '1985-08-21', 'Male',     'Phoenix',         'Arizona',         '85004', 'Gold',     '2023-02-18'),
('Scarlett',  'Robinson',   'scarlett.robinson@email.com',  '415-555-1029', '1991-12-30', 'Female',   'San Francisco',   'California',      '94103', 'Bronze',   '2023-07-08'),
('Owen',      'Walker',     'owen.walker@email.com',        '206-555-1030', '1989-06-13', 'Male',     'Seattle',         'Washington',      '98102', 'Platinum', '2023-01-08'),
('Chloe',     'Young',      'chloe.young@email.com',        '212-555-1031', '1996-09-24', 'Female',   'New York',       'New York',         '10010', 'Gold',     '2023-12-01'),
('Aiden',     'Allen',      'aiden.allen@email.com',         '617-555-1032', '1984-02-07', 'Male',     'Boston',          'Massachusetts',   '02134', 'Silver',   '2023-04-20'),
('Lily',      'King',       'lily.king@email.com',           '404-555-1033', '1993-05-19', 'Female',   'Atlanta',         'Georgia',         '30312', 'Bronze',   '2024-01-05'),
('Matthew',   'Wright',     'matthew.wright@email.com',      '305-555-1034', '1990-11-02', 'Male',     'Miami',           'Florida',         '33130', 'Gold',     '2023-06-10'),
('Aria',      'Scott',      'aria.scott@email.com',          '312-555-1035', '1988-07-27', 'Female',   'Chicago',         'Illinois',        '60657', 'Platinum', '2023-01-18'),
('Jacob',     'Torres',     'jacob.torres@email.com',        '952-555-1036', '1997-01-14', 'Male',     'Minneapolis',     'Minnesota',       '55408', 'Bronze',   '2023-08-22'),
('Riley',     'Nguyen',     'riley.nguyen@email.com',        '972-555-1037', '1986-10-08', 'Female',   'Dallas',          'Texas',           '75204', 'Silver',   '2024-02-01'),
('Logan',     'Hill',       'logan.hill@email.com',           '602-555-1038', '1994-03-31', 'Male',     'Phoenix',         'Arizona',         '85008', 'Gold',     '2023-05-14'),
('Zoey',      'Flores',     'zoey.flores@email.com',         '415-555-1039', '1992-08-16', 'Female',   'San Francisco',   'California',      '94107', 'Bronze',   '2023-09-30'),
('Jackson',   'Green',      'jackson.green@email.com',       '206-555-1040', '1983-04-25', 'Male',     'Seattle',         'Washington',      '98103', 'Silver',   '2023-02-28'),
('Penelope',  'Adams',      'penelope.adams@email.com',      '212-555-1041', '1995-12-11', 'Female',   'New York',       'New York',         '10011', 'Gold',     '2024-01-15'),
('Luke',      'Nelson',     'luke.nelson@email.com',          '617-555-1042', '1989-06-28', 'Male',     'Boston',          'Massachusetts',   '02127', 'Platinum', '2023-03-12'),
('Layla',     'Baker',      'layla.baker@email.com',          '404-555-1043', '1991-09-05', 'Female',   'Atlanta',         'Georgia',         '30316', 'Bronze',   '2023-07-25'),
('Gabriel',   'Hall',       'gabriel.hall@email.com',         '305-555-1044', '1987-02-18', 'Male',     'Miami',           'Florida',         '33135', 'Silver',   '2024-03-01'),
('Nora',      'Rivera',     'nora.rivera@email.com',          '312-555-1045', '1998-05-12', 'Female',   'Chicago',         'Illinois',        '60618', 'Gold',     '2023-10-08'),
('Carter',    'Campbell',   'carter.campbell@email.com',      '952-555-1046', '1985-11-30', 'Male',     'Minneapolis',     'Minnesota',       '55410', 'Bronze',   '2023-04-02'),
('Hannah',    'Mitchell',   'hannah.mitchell@email.com',      '972-555-1047', '1993-07-22', 'Female',   'Dallas',          'Texas',           '75206', 'Platinum', '2023-01-28'),
('Jayden',    'Roberts',    'jayden.roberts@email.com',       '602-555-1048', '1990-01-09', 'Male',     'Phoenix',         'Arizona',         '85012', 'Silver',   '2023-06-05'),
('Addison',   'Carter',     'addison.carter@email.com',       '415-555-1049', '1986-10-14', 'Female',   'San Francisco',   'California',      '94110', 'Gold',     '2024-04-01'),
('Dylan',     'Phillips',   'dylan.phillips@email.com',       '206-555-1050', '1994-03-06', 'Male',     'Seattle',         'Washington',      '98104', 'Bronze',   '2023-08-15'),
('Aubrey',    'Evans',      'aubrey.evans@email.com',         '212-555-1051', '1992-06-19', 'Female',   'New York',       'New York',         '10012', 'Silver',   '2023-11-20'),
('Nathan',    'Turner',     'nathan.turner@email.com',        '617-555-1052', '1988-12-01', 'Male',     'Boston',          'Massachusetts',   '02130', 'Gold',     '2023-02-25'),
('Stella',    'Parker',     'stella.parker@email.com',        '404-555-1053', '1996-04-15', 'Female',   'Atlanta',         'Georgia',         '30318', 'Platinum', '2023-05-30'),
('Caleb',     'Edwards',    'caleb.edwards@email.com',        '305-555-1054', '1984-08-28', 'Male',     'Miami',           'Florida',         '33140', 'Bronze',   '2023-09-18'),
('Savannah',  'Collins',    'savannah.collins@email.com',     '312-555-1055', '1991-01-07', 'Female',   'Chicago',         'Illinois',        '60622', 'Silver',   '2024-05-01'),
('Isaac',     'Stewart',    'isaac.stewart@email.com',        '952-555-1056', '1987-10-23', 'Male',     'Minneapolis',     'Minnesota',       '55414', 'Gold',     '2023-03-18'),
('Victoria',  'Sanchez2',   'victoria.sanchez2@email.com',    '972-555-1057', '1995-05-08', 'Female',   'Dallas',          'Texas',           '75207', 'Bronze',   '2023-07-12'),
('Leo',       'Morris',     'leo.morris@email.com',           '602-555-1058', '1989-09-14', 'Male',     'Phoenix',         'Arizona',         '85014', 'Platinum', '2023-01-10'),
('Violet',    'Rogers',     'violet.rogers@email.com',        '415-555-1059', '1993-02-26', 'Female',   'San Francisco',   'California',      '94112', 'Silver',   '2024-06-01'),
('David',     'Reed',       'david.reed@email.com',           '206-555-1060', '1986-07-03', 'Male',     'Seattle',         'Washington',      '98106', 'Gold',     '2023-10-25'),
-- Customers 61-100
('Hazel',     'Cook',       'hazel.cook@email.com',           '212-555-1061', '1997-11-16', 'Female',   'New York',       'New York',         '10013', 'Bronze',   '2023-12-10'),
('Elijah',    'Morgan',     'elijah.morgan@email.com',        '617-555-1062', '1990-04-02', 'Male',     'Boston',          'Massachusetts',   '02135', 'Silver',   '2023-04-28'),
('Aurora',    'Bell',       'aurora.bell@email.com',           '404-555-1063', '1988-08-20', 'Female',   'Atlanta',         'Georgia',         '30319', 'Gold',     '2024-01-20'),
('Lincoln',   'Murphy',     'lincoln.murphy@email.com',       '305-555-1064', '1992-01-12', 'Male',     'Miami',           'Florida',         '33142', 'Platinum', '2023-06-22'),
('Luna',      'Bailey',     'luna.bailey@email.com',           '312-555-1065', '1994-06-07', 'Female',   'Chicago',         'Illinois',        '60625', 'Bronze',   '2023-08-04'),
('Mateo',     'Rivera2',    'mateo.rivera2@email.com',         '952-555-1066', '1985-03-18', 'Male',     'Minneapolis',     'Minnesota',       '55416', 'Silver',   '2023-11-15'),
('Willow',    'Cooper',     'willow.cooper@email.com',         '972-555-1067', '1996-10-29', 'Female',   'Dallas',          'Texas',           '75208', 'Gold',     '2024-02-10'),
('Asher',     'Richardson', 'asher.richardson@email.com',      '602-555-1068', '1987-05-04', 'Male',     'Phoenix',         'Arizona',         '85018', 'Bronze',   '2023-05-08'),
('Emilia',    'Cox',        'emilia.cox@email.com',            '415-555-1069', '1993-12-21', 'Female',   'San Francisco',   'California',      '94114', 'Platinum', '2023-01-22'),
('Thomas',    'Howard',     'thomas.howard@email.com',         '206-555-1070', '1989-07-16', 'Male',     'Seattle',         'Washington',      '98107', 'Silver',   '2024-03-15'),
('Ivy',       'Ward',       'ivy.ward@email.com',              '212-555-1071', '1991-02-09', 'Female',   'New York',       'New York',         '10014', 'Gold',     '2023-09-01'),
('Samuel',    'Torres2',    'samuel.torres2@email.com',        '617-555-1072', '1986-09-25', 'Male',     'Boston',          'Massachusetts',   '02138', 'Bronze',   '2023-03-22'),
('Paisley',   'Peterson',   'paisley.peterson@email.com',      '404-555-1073', '1998-04-11', 'Female',   'Atlanta',         'Georgia',         '30322', 'Silver',   '2024-07-01'),
('Joseph',    'Gray',       'joseph.gray@email.com',           '305-555-1074', '1984-11-28', 'Male',     'Miami',           'Florida',         '33145', 'Gold',     '2023-07-18'),
('Eleanor',   'Ramirez2',   'eleanor.ramirez2@email.com',      '312-555-1075', '1990-06-14', 'Female',   'Chicago',         'Illinois',        '60630', 'Platinum', '2023-01-15'),
('Levi',      'James',      'levi.james@email.com',            '952-555-1076', '1995-01-03', 'Male',     'Minneapolis',     'Minnesota',       '55418', 'Bronze',   '2023-10-12'),
('Naomi',     'Watson',     'naomi.watson@email.com',          '972-555-1077', '1988-08-19', 'Female',   'Dallas',          'Texas',           '75209', 'Silver',   '2023-04-08'),
('Andrew',    'Brooks',     'andrew.brooks@email.com',         '602-555-1078', '1993-03-22', 'Male',     'Phoenix',         'Arizona',         '85020', 'Gold',     '2024-04-15'),
('Elena',     'Kelly',      'elena.kelly@email.com',           '415-555-1079', '1986-10-07', 'Female',   'San Francisco',   'California',      '94115', 'Bronze',   '2023-06-30'),
('Christopher','Sanders',   'christopher.sanders@email.com',   '206-555-1080', '1992-05-26', 'Male',     'Seattle',         'Washington',      '98108', 'Platinum', '2023-02-05'),
-- Customers 81-120
('Clara',     'Price',      'clara.price@email.com',           '212-555-1081', '1994-09-18', 'Female',   'New York',       'New York',         '10016', 'Silver',   '2024-05-10'),
('Adrian',    'Bennett',    'adrian.bennett@email.com',        '617-555-1082', '1987-12-12', 'Male',     'Boston',          'Massachusetts',   '02139', 'Gold',     '2023-08-18'),
('Madeline',  'Wood',       'madeline.wood@email.com',         '404-555-1083', '1991-04-05', 'Female',   'Atlanta',         'Georgia',         '30324', 'Bronze',   '2023-11-28'),
('Dominic',   'Barnes',     'dominic.barnes@email.com',        '305-555-1084', '1989-07-28', 'Male',     'Miami',           'Florida',         '33146', 'Platinum', '2023-01-02'),
('Ellie',     'Ross',       'ellie.ross@email.com',            '312-555-1085', '1996-02-14', 'Female',   'Chicago',         'Illinois',        '60634', 'Silver',   '2024-06-15'),
('Miles',     'Henderson',  'miles.henderson@email.com',       '952-555-1086', '1983-10-30', 'Male',     'Minneapolis',     'Minnesota',       '55419', 'Gold',     '2023-05-02'),
('Mackenzie', 'Coleman',    'mackenzie.coleman@email.com',     '972-555-1087', '1995-06-23', 'Female',   'Dallas',          'Texas',           '75210', 'Bronze',   '2023-09-25'),
('Charles',   'Jenkins',    'charles.jenkins@email.com',       '602-555-1088', '1988-01-17', 'Male',     'Phoenix',         'Arizona',         '85022', 'Silver',   '2024-01-28'),
('Piper',     'Perry',      'piper.perry@email.com',           '415-555-1089', '1993-08-06', 'Female',   'San Francisco',   'California',      '94116', 'Platinum', '2023-03-08'),
('Ezra',      'Powell',     'ezra.powell@email.com',           '206-555-1090', '1990-03-11', 'Male',     'Seattle',         'Washington',      '98109', 'Gold',     '2023-07-30'),
('Bella',     'Long',       'bella.long@email.com',            '212-555-1091', '1997-05-28', 'Female',   'New York',       'New York',         '10017', 'Bronze',   '2024-02-20'),
('Aaron',     'Patterson',  'aaron.patterson@email.com',       '617-555-1092', '1986-11-09', 'Male',     'Boston',          'Massachusetts',   '02140', 'Silver',   '2023-06-14'),
('Alice',     'Hughes',     'alice.hughes@email.com',          '404-555-1093', '1992-02-22', 'Female',   'Atlanta',         'Georgia',         '30326', 'Gold',     '2023-12-05'),
('Chase',     'Flores2',    'chase.flores2@email.com',         '305-555-1094', '1985-09-15', 'Male',     'Miami',           'Florida',         '33147', 'Bronze',   '2024-07-10'),
('Ruby',      'Washington', 'ruby.washington@email.com',       '312-555-1095', '1994-04-01', 'Female',   'Chicago',         'Illinois',        '60637', 'Platinum', '2023-01-25'),
('Hunter',    'Butler',     'hunter.butler@email.com',         '952-555-1096', '1991-10-18', 'Male',     'Minneapolis',     'Minnesota',       '55420', 'Silver',   '2023-08-10'),
('Madelyn',   'Simmons',    'madelyn.simmons@email.com',       '972-555-1097', '1987-06-05', 'Female',   'Dallas',          'Texas',           '75211', 'Gold',     '2024-03-18'),
('Eli',       'Foster',     'eli.foster@email.com',            '602-555-1098', '1993-01-20', 'Male',     'Phoenix',         'Arizona',         '85024', 'Bronze',   '2023-05-22'),
('Kennedy',   'Gonzales',   'kennedy.gonzales@email.com',      '415-555-1099', '1989-08-31', 'Female',   'San Francisco',   'California',      '94117', 'Silver',   '2023-10-15'),
('Ryan',      'Bryant',     'ryan.bryant@email.com',           '206-555-1100', '1996-12-14', 'Male',     'Seattle',         'Washington',      '98110', 'Gold',     '2024-04-28'),
-- Customers 101-140
('Sadie',     'Alexander',  'sadie.alexander@email.com',       '212-555-1101', '1990-07-07', 'Female',   'New York',       'New York',         '10018', 'Platinum', '2023-02-12'),
('Jason',     'Russell',    'jason.russell@email.com',          '617-555-1102', '1984-03-24', 'Male',     'Boston',          'Massachusetts',   '02141', 'Bronze',   '2023-09-05'),
('Autumn',    'Griffin',    'autumn.griffin@email.com',         '404-555-1103', '1992-10-16', 'Female',   'Atlanta',         'Georgia',         '30327', 'Silver',   '2024-01-10'),
('Zachary',   'Diaz',       'zachary.diaz@email.com',          '305-555-1104', '1988-05-09', 'Male',     'Miami',           'Florida',         '33149', 'Gold',     '2023-04-25'),
('Nevaeh',    'Hayes',      'nevaeh.hayes@email.com',          '312-555-1105', '1995-12-28', 'Female',   'Chicago',         'Illinois',        '60640', 'Bronze',   '2023-07-08'),
('Adam',      'Myers',      'adam.myers@email.com',            '952-555-1106', '1987-06-11', 'Male',     'Minneapolis',     'Minnesota',       '55422', 'Platinum', '2023-01-18'),
('Leah',      'Ford',       'leah.ford@email.com',             '972-555-1107', '1993-09-03', 'Female',   'Dallas',          'Texas',           '75212', 'Silver',   '2023-11-22'),
('Tyler',     'Hamilton',   'tyler.hamilton@email.com',        '602-555-1108', '1986-02-26', 'Male',     'Phoenix',         'Arizona',         '85026', 'Gold',     '2024-05-15'),
('Samantha',  'Graham',     'samantha.graham@email.com',       '415-555-1109', '1994-07-19', 'Female',   'San Francisco',   'California',      '94118', 'Bronze',   '2023-06-02'),
('Nicholas',  'Sullivan',   'nicholas.sullivan@email.com',     '206-555-1110', '1991-11-05', 'Male',     'Seattle',         'Washington',      '98112', 'Silver',   '2023-09-28'),
('Skylar',    'Wallace',    'skylar.wallace@email.com',        '212-555-1111', '1989-04-22', 'Female',   'New York',       'New York',         '10019', 'Gold',     '2024-02-08'),
('Ian',       'Woods',      'ian.woods@email.com',             '617-555-1112', '1996-08-10', 'Male',     'Boston',          'Massachusetts',   '02142', 'Platinum', '2023-03-15'),
('Brooklyn',  'Cole',       'brooklyn.cole@email.com',         '404-555-1113', '1985-01-27', 'Female',   'Atlanta',         'Georgia',         '30328', 'Bronze',   '2023-10-20'),
('Robert',    'West',       'robert.west@email.com',           '305-555-1114', '1993-06-08', 'Male',     'Miami',           'Florida',         '33150', 'Silver',   '2024-06-25'),
('Kinsley',   'Jordan',     'kinsley.jordan@email.com',        '312-555-1115', '1988-11-21', 'Female',   'Chicago',         'Illinois',        '60641', 'Gold',     '2023-01-05'),
('Timothy',   'Owens',      'timothy.owens@email.com',        '952-555-1116', '1994-02-13', 'Male',     'Minneapolis',     'Minnesota',       '55424', 'Bronze',   '2023-08-28'),
('Lucy',      'Reynolds',   'lucy.reynolds@email.com',         '972-555-1117', '1990-09-06', 'Female',   'Dallas',          'Texas',           '75214', 'Platinum', '2023-04-12'),
('Justin',    'Fisher',     'justin.fisher@email.com',         '602-555-1118', '1987-04-29', 'Male',     'Phoenix',         'Arizona',         '85028', 'Silver',   '2023-12-18'),
('Delilah',   'Ellis',      'delilah.ellis@email.com',         '415-555-1119', '1995-07-12', 'Female',   'San Francisco',   'California',      '94121', 'Gold',     '2024-03-05'),
('Kevin',     'Harrison',   'kevin.harrison@email.com',        '206-555-1120', '1982-10-24', 'Male',     'Seattle',         'Washington',      '98115', 'Bronze',   '2023-07-15'),
-- Customers 141-180
('Sophie',    'Gibson',     'sophie.gibson@email.com',         '212-555-1141', '1991-03-18', 'Female',   'New York',       'New York',         '10020', 'Silver',   '2024-01-22'),
('Brandon',   'McDonald',   'brandon.mcdonald@email.com',     '617-555-1142', '1988-08-05', 'Male',     'Boston',          'Massachusetts',   '02143', 'Gold',     '2023-05-10'),
('Anastasia', 'Cruz',       'anastasia.cruz@email.com',       '404-555-1143', '1993-12-11', 'Female',   'Atlanta',         'Georgia',         '30330', 'Platinum', '2023-02-14'),
('Blake',     'Marshall',   'blake.marshall@email.com',        '305-555-1144', '1986-05-27', 'Male',     'Miami',           'Florida',         '33152', 'Bronze',   '2023-10-05'),
('Katherine', 'Ortiz',      'katherine.ortiz@email.com',       '312-555-1145', '1994-10-03', 'Female',   'Chicago',         'Illinois',        '60643', 'Silver',   '2024-07-15'),
('Derek',     'Gomez',      'derek.gomez@email.com',           '952-555-1146', '1989-02-16', 'Male',     'Minneapolis',     'Minnesota',       '55426', 'Gold',     '2023-06-20'),
('Genevieve', 'Murray',     'genevieve.murray@email.com',     '972-555-1147', '1997-07-08', 'Female',   'Dallas',          'Texas',           '75215', 'Bronze',   '2023-11-08'),
('Patrick',   'Freeman',    'patrick.freeman@email.com',       '602-555-1148', '1985-04-21', 'Male',     'Phoenix',         'Arizona',         '85030', 'Platinum', '2023-01-28'),
('Margaret',  'Wells',      'margaret.wells@email.com',        '415-555-1149', '1992-09-14', 'Female',   'San Francisco',   'California',      '94122', 'Silver',   '2024-04-10'),
('Travis',    'Webb',       'travis.webb@email.com',           '206-555-1150', '1990-01-30', 'Male',     'Seattle',         'Washington',      '98116', 'Gold',     '2023-08-02'),
('Josephine', 'Simpson',    'josephine.simpson@email.com',     '212-555-1151', '1996-06-22', 'Female',   'New York',       'New York',         '10021', 'Bronze',   '2023-03-28'),
('Derek',     'Stevens',    'derek.stevens@email.com',         '617-555-1152', '1984-11-15', 'Male',     'Boston',          'Massachusetts',   '02144', 'Platinum', '2023-09-12'),
('Athena',    'Tucker',     'athena.tucker@email.com',         '404-555-1153', '1991-05-06', 'Female',   'Atlanta',         'Georgia',         '30332', 'Silver',   '2024-02-15'),
('Marcus',    'Porter',     'marcus.porter@email.com',         '305-555-1154', '1988-10-19', 'Male',     'Miami',           'Florida',         '33154', 'Gold',     '2023-05-30'),
('Iris',      'Hunter',     'iris.hunter@email.com',           '312-555-1155', '1995-03-02', 'Female',   'Chicago',         'Illinois',        '60645', 'Bronze',   '2023-12-22'),
('Simon',     'Hicks',      'simon.hicks@email.com',           '952-555-1156', '1987-08-25', 'Male',     'Minneapolis',     'Minnesota',       '55428', 'Silver',   '2024-05-18'),
('Alexandra', 'Crawford',   'alexandra.crawford@email.com',    '972-555-1157', '1993-01-08', 'Female',   'Dallas',          'Texas',           '75216', 'Gold',     '2023-07-05'),
('Grant',     'Henry',      'grant.henry@email.com',           '602-555-1158', '1990-06-20', 'Male',     'Phoenix',         'Arizona',         '85032', 'Platinum', '2023-01-14'),
('Madeleine', 'Boyd',       'madeleine.boyd@email.com',       '415-555-1159', '1986-11-03', 'Female',   'San Francisco',   'California',      '94123', 'Bronze',   '2023-10-30'),
('Wesley',    'Mason',      'wesley.mason@email.com',          '206-555-1160', '1994-04-15', 'Male',     'Seattle',         'Washington',      '98117', 'Silver',   '2024-06-08'),
-- Customers 181-200
('Vivienne',  'Morales',    'vivienne.morales@email.com',      '212-555-1161', '1992-08-29', 'Female',   'New York',       'New York',         '10022', 'Gold',     '2023-04-18'),
('Peter',     'Kennedy',    'peter.kennedy@email.com',         '617-555-1162', '1989-01-12', 'Male',     'Boston',          'Massachusetts',   '02145', 'Bronze',   '2023-11-02'),
('Rosalie',   'Warren',     'rosalie.warren@email.com',        '404-555-1163', '1996-06-05', 'Female',   'Atlanta',         'Georgia',         '30334', 'Platinum', '2023-02-20'),
('Keith',     'Dixon',      'keith.dixon@email.com',           '305-555-1164', '1983-09-18', 'Male',     'Miami',           'Florida',         '33155', 'Silver',   '2024-03-12'),
('Molly',     'Ramos',      'molly.ramos@email.com',           '312-555-1165', '1991-12-07', 'Female',   'Chicago',         'Illinois',        '60647', 'Gold',     '2023-06-25'),
('Raymond',   'Reyes',      'raymond.reyes@email.com',        '952-555-1166', '1988-03-30', 'Male',     'Minneapolis',     'Minnesota',       '55430', 'Bronze',   '2023-09-08'),
('Daisy',     'Burns',      'daisy.burns@email.com',           '972-555-1167', '1994-10-22', 'Female',   'Dallas',          'Texas',           '75218', 'Platinum', '2023-01-08'),
('George',    'Gordon',     'george.gordon@email.com',         '602-555-1168', '1987-05-14', 'Male',     'Phoenix',         'Arizona',         '85034', 'Silver',   '2024-07-20'),
('Camilla',   'Shaw',       'camilla.shaw@email.com',          '415-555-1169', '1993-02-08', 'Female',   'San Francisco',   'California',      '94124', 'Gold',     '2023-08-12'),
('Phillip',   'Snyder',     'phillip.snyder@email.com',        '206-555-1170', '1990-07-25', 'Male',     'Seattle',         'Washington',      '98118', 'Bronze',   '2023-03-02'),
('Sienna',    'Palmer',     'sienna.palmer@email.com',         '212-555-1171', '1986-04-17', 'Female',   'New York',       'New York',         '10023', 'Platinum', '2023-12-15'),
('Russell',   'Ward2',      'russell.ward2@email.com',         '617-555-1172', '1995-09-02', 'Male',     'Boston',          'Massachusetts',   '02146', 'Silver',   '2024-04-22'),
('Lila',      'Weber',      'lila.weber@email.com',            '404-555-1173', '1989-12-28', 'Female',   'Atlanta',         'Georgia',         '30336', 'Gold',     '2023-07-28'),
('Craig',     'Stone',      'craig.stone@email.com',           '305-555-1174', '1992-03-14', 'Male',     'Miami',           'Florida',         '33156', 'Bronze',   '2023-10-08'),
('Eva',       'Holmes',     'eva.holmes@email.com',            '312-555-1175', '1988-06-21', 'Female',   'Chicago',         'Illinois',        '60649', 'Platinum', '2023-02-02'),
('Sean',      'Kelley',     'sean.kelley@email.com',           '952-555-1176', '1993-11-10', 'Male',     'Minneapolis',     'Minnesota',       '55432', 'Silver',   '2023-05-16'),
('Gabriella', 'Meyer',      'gabriella.meyer@email.com',      '972-555-1177', '1990-04-03', 'Female',   'Dallas',          'Texas',           '75219', 'Gold',     '2024-01-05'),
('Keith',     'Fox',        'keith.fox@email.com',             '602-555-1178', '1986-08-16', 'Male',     'Phoenix',         'Arizona',         '85036', 'Bronze',   '2023-08-30'),
('Alina',     'Schmidt',    'alina.schmidt@email.com',         '415-555-1179', '1994-01-29', 'Female',   'San Francisco',   'California',      '94126', 'Platinum', '2023-04-04'),
('Douglas',   'Chang',      'douglas.chang@email.com',        '206-555-1180', '1987-07-12', 'Male',     'Seattle',         'Washington',      '98119', 'Gold',     '2024-06-12');

-- ============================================================================
-- TRANSACTIONS & TRANSACTION ITEMS
-- 2000+ transactions with 5000+ line items spanning Jan 2024 — Dec 2025
-- Generated with realistic seasonal patterns:
--   - Higher volume in Nov-Dec (holiday season)
--   - Summer bump in Jun-Jul
--   - Lower volume in Jan-Feb
-- ============================================================================

-- We'll use a DO block to generate realistic transaction data
DO $$
DECLARE
    v_txn_id INTEGER;
    v_customer_id INTEGER;
    v_store_id INTEGER;
    v_product_id INTEGER;
    v_txn_date TIMESTAMP;
    v_payment_methods TEXT[] := ARRAY['Credit Card', 'Debit Card', 'Cash', 'Mobile Payment', 'Gift Card', 'Store Credit'];
    v_payment VARCHAR(30);
    v_quantity INTEGER;
    v_price NUMERIC(10,2);
    v_discount_pct NUMERIC(5,2);
    v_line_total NUMERIC(12,2);
    v_subtotal NUMERIC(12,2);
    v_discount_amount NUMERIC(12,2);
    v_tax_rate NUMERIC(5,4) := 0.0825; -- 8.25% tax
    v_tax_amount NUMERIC(12,2);
    v_total_amount NUMERIC(12,2);
    v_items_per_txn INTEGER;
    v_month INTEGER;
    v_txns_this_month INTEGER;
    v_year INTEGER;
    v_day INTEGER;
    v_hour INTEGER;
    v_minute INTEGER;
    v_base_txns INTEGER;
    v_max_customers INTEGER;
    v_max_products INTEGER;
    v_discount_roll NUMERIC;
    v_status VARCHAR(20);
    v_status_roll NUMERIC;
BEGIN
    -- Get counts
    SELECT COUNT(*) INTO v_max_customers FROM customers;
    SELECT COUNT(*) INTO v_max_products FROM products;

    -- Loop through each month from Jan 2024 to Dec 2025
    FOR v_year IN 2024..2025 LOOP
        FOR v_month IN 1..12 LOOP
            -- Seasonal transaction volume
            v_base_txns := CASE
                WHEN v_month IN (11, 12) THEN 130  -- Holiday peak
                WHEN v_month IN (6, 7) THEN 100    -- Summer bump
                WHEN v_month IN (1, 2) THEN 60     -- Post-holiday dip
                WHEN v_month IN (3, 4, 5) THEN 80  -- Spring
                ELSE 85                             -- Normal
            END;

            -- Add some year-over-year growth for 2025
            IF v_year = 2025 THEN
                v_base_txns := (v_base_txns * 1.12)::INTEGER;
            END IF;

            -- Add randomness (+/- 15%)
            v_txns_this_month := v_base_txns + (random() * v_base_txns * 0.3 - v_base_txns * 0.15)::INTEGER;

            FOR i IN 1..v_txns_this_month LOOP
                -- Random day, hour, minute
                v_day := LEAST((random() * 27 + 1)::INTEGER, 28);
                v_hour := (random() * 13 + 8)::INTEGER;  -- 8 AM to 9 PM
                v_minute := (random() * 59)::INTEGER;

                v_txn_date := make_timestamp(v_year, v_month, v_day, v_hour, v_minute, 0);

                -- Random customer and store
                v_customer_id := (random() * (v_max_customers - 1) + 1)::INTEGER;
                v_store_id := (random() * 9 + 1)::INTEGER;

                -- Random payment method
                v_payment := v_payment_methods[(random() * 5 + 1)::INTEGER];

                -- Random order status (95% Completed, 2% Returned, 2% Cancelled, 1% Refunded)
                v_status_roll := random();
                v_status := CASE
                    WHEN v_status_roll < 0.95 THEN 'Completed'
                    WHEN v_status_roll < 0.97 THEN 'Returned'
                    WHEN v_status_roll < 0.99 THEN 'Cancelled'
                    ELSE 'Refunded'
                END;

                -- Items per transaction (1-6, weighted toward 2-3)
                v_items_per_txn := GREATEST(1, LEAST(6, (random() * 3 + 1 + random() * 2)::INTEGER));

                v_subtotal := 0;

                -- Create the transaction first with placeholder amounts
                INSERT INTO transactions (transaction_date, customer_id, store_id, payment_method, subtotal, discount_amount, tax_amount, total_amount, order_status)
                VALUES (v_txn_date, v_customer_id, v_store_id, v_payment, 0, 0, 0, 0, v_status)
                RETURNING transaction_id INTO v_txn_id;

                -- Generate line items
                FOR j IN 1..v_items_per_txn LOOP
                    v_product_id := (random() * (v_max_products - 1) + 1)::INTEGER;
                    v_quantity := GREATEST(1, LEAST(5, (random() * 3 + 1)::INTEGER));

                    SELECT unit_price INTO v_price FROM products WHERE product_id = v_product_id;

                    -- Random discount (70% no discount, 20% gets 5-15%, 10% gets 20-30%)
                    v_discount_roll := random();
                    v_discount_pct := CASE
                        WHEN v_discount_roll < 0.70 THEN 0
                        WHEN v_discount_roll < 0.90 THEN (random() * 10 + 5)::NUMERIC(5,2)
                        ELSE (random() * 10 + 20)::NUMERIC(5,2)
                    END;

                    v_line_total := ROUND(v_quantity * v_price * (1 - v_discount_pct / 100), 2);

                    INSERT INTO transaction_items (transaction_id, product_id, quantity, unit_price, discount_pct, line_total)
                    VALUES (v_txn_id, v_product_id, v_quantity, v_price, v_discount_pct, v_line_total);

                    v_subtotal := v_subtotal + v_line_total;
                END LOOP;

                -- Calculate totals
                v_discount_amount := ROUND(v_subtotal * CASE WHEN random() < 0.15 THEN (random() * 5 + 2) / 100 ELSE 0 END, 2);
                v_tax_amount := ROUND((v_subtotal - v_discount_amount) * v_tax_rate, 2);
                v_total_amount := v_subtotal - v_discount_amount + v_tax_amount;

                -- Update transaction with calculated amounts
                UPDATE transactions
                SET subtotal = v_subtotal,
                    discount_amount = v_discount_amount,
                    tax_amount = v_tax_amount,
                    total_amount = v_total_amount
                WHERE transaction_id = v_txn_id;

            END LOOP;
        END LOOP;
    END LOOP;

    RAISE NOTICE 'Seed data generation complete!';
    RAISE NOTICE 'Transactions created: %', (SELECT COUNT(*) FROM transactions);
    RAISE NOTICE 'Transaction items created: %', (SELECT COUNT(*) FROM transaction_items);
END $$;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================
-- Quick counts to verify data generation
SELECT 'Stores' AS entity, COUNT(*) AS count FROM stores
UNION ALL
SELECT 'Products', COUNT(*) FROM products
UNION ALL
SELECT 'Customers', COUNT(*) FROM customers
UNION ALL
SELECT 'Transactions', COUNT(*) FROM transactions
UNION ALL
SELECT 'Transaction Items', COUNT(*) FROM transaction_items;
