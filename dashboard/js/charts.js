/**
 * Charts Module — Chart.js chart configurations and rendering.
 * Creates: Revenue Trend (line), Category Mix (doughnut),
 *          Top Products (horizontal bar), Store Comparison (bar),
 *          Customer Segments (polar), Payment Methods (bar).
 */

const Charts = (() => {
    let charts = {};
    let data = null;

    // Global Chart.js defaults
    function setDefaults() {
        Chart.defaults.color = '#94a3b8';
        Chart.defaults.borderColor = 'rgba(255, 255, 255, 0.06)';
        Chart.defaults.font.family = "'Inter', sans-serif";
        Chart.defaults.font.size = 12;
        Chart.defaults.plugins.legend.labels.usePointStyle = true;
        Chart.defaults.plugins.legend.labels.pointStyle = 'circle';
        Chart.defaults.plugins.legend.labels.padding = 16;
        Chart.defaults.plugins.tooltip.backgroundColor = 'rgba(19, 24, 66, 0.95)';
        Chart.defaults.plugins.tooltip.titleFont = { weight: '600' };
        Chart.defaults.plugins.tooltip.padding = 12;
        Chart.defaults.plugins.tooltip.cornerRadius = 8;
        Chart.defaults.plugins.tooltip.borderColor = 'rgba(255, 255, 255, 0.1)';
        Chart.defaults.plugins.tooltip.borderWidth = 1;
        Chart.defaults.animation = { duration: 1200, easing: 'easeOutQuart' };
    }

    function init(analyticsData) {
        data = analyticsData;
        setDefaults();
        createRevenueChart();
        createCategoryChart();
        createProductsChart();
        createStoreChart();
        createSegmentChart();
        createPaymentChart();
    }

    // ========================================================================
    // 1. REVENUE TREND (Line Chart — Full Width)
    // ========================================================================
    function createRevenueChart() {
        const ctx = document.getElementById('revenueChart');
        if (!ctx || !data.monthly_revenue) return;

        const monthly = data.monthly_revenue;
        const labels = monthly.map(m => {
            const parts = m.month.split('-');
            const monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                               'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            return monthNames[parseInt(parts[1])] + ' ' + parts[0].slice(2);
        });

        const gradient = ctx.getContext('2d');
        const revenueGradient = gradient.createLinearGradient(0, 0, 0, 380);
        revenueGradient.addColorStop(0, 'rgba(0, 212, 255, 0.25)');
        revenueGradient.addColorStop(1, 'rgba(0, 212, 255, 0.0)');

        charts.revenue = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Monthly Revenue',
                        data: monthly.map(m => m.revenue),
                        borderColor: '#00d4ff',
                        backgroundColor: revenueGradient,
                        borderWidth: 2.5,
                        fill: true,
                        tension: 0.4,
                        pointRadius: 3,
                        pointHoverRadius: 6,
                        pointBackgroundColor: '#00d4ff',
                        pointBorderColor: '#0a0e27',
                        pointBorderWidth: 2,
                    },
                    {
                        label: '3-Month Moving Avg',
                        data: monthly.map(m => m.moving_avg),
                        borderColor: '#7c3aed',
                        borderWidth: 2,
                        borderDash: [6, 4],
                        fill: false,
                        tension: 0.4,
                        pointRadius: 0,
                        pointHoverRadius: 4,
                    },
                ],
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: {
                    mode: 'index',
                    intersect: false,
                },
                plugins: {
                    legend: {
                        position: 'top',
                        align: 'end',
                    },
                    tooltip: {
                        callbacks: {
                            label: (ctx) => {
                                const value = Utils.formatCurrency(ctx.parsed.y);
                                return `${ctx.dataset.label}: ${value}`;
                            },
                        },
                    },
                },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: { maxRotation: 0, autoSkip: true, maxTicksLimit: 12 },
                    },
                    y: {
                        grid: { color: 'rgba(255, 255, 255, 0.04)' },
                        ticks: {
                            callback: (val) => Utils.formatCurrency(val, true),
                        },
                    },
                },
            },
        });
    }

    // ========================================================================
    // 2. CATEGORY MIX (Doughnut Chart)
    // ========================================================================
    function createCategoryChart() {
        const ctx = document.getElementById('categoryChart');
        if (!ctx || !data.categories) return;

        const categories = data.categories;

        charts.category = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: categories.map(c => c.category),
                datasets: [{
                    data: categories.map(c => c.revenue),
                    backgroundColor: Utils.chartColors.slice(0, categories.length),
                    borderColor: '#0a0e27',
                    borderWidth: 2,
                    hoverOffset: 8,
                }],
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '65%',
                plugins: {
                    legend: {
                        position: 'right',
                        labels: { font: { size: 11 }, padding: 12 },
                    },
                    tooltip: {
                        callbacks: {
                            label: (ctx) => {
                                const value = Utils.formatCurrency(ctx.parsed);
                                const pct = categories[ctx.dataIndex].share_pct;
                                return `${ctx.label}: ${value} (${pct}%)`;
                            },
                        },
                    },
                },
            },
        });
    }

    // ========================================================================
    // 3. TOP PRODUCTS (Horizontal Bar Chart)
    // ========================================================================
    function createProductsChart() {
        const ctx = document.getElementById('productsChart');
        if (!ctx || !data.top_products) return;

        const products = data.top_products.slice(0, 10);

        charts.products = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: products.map(p => {
                    const name = p.name;
                    return name.length > 25 ? name.substring(0, 25) + '...' : name;
                }),
                datasets: [{
                    label: 'Revenue',
                    data: products.map(p => p.revenue),
                    backgroundColor: products.map((_, i) =>
                        Utils.chartColors[i % Utils.chartColors.length]
                    ),
                    borderColor: 'transparent',
                    borderWidth: 0,
                    borderRadius: 4,
                    barThickness: 20,
                }],
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                indexAxis: 'y',
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            title: (items) => {
                                const idx = items[0].dataIndex;
                                return products[idx].name;
                            },
                            label: (ctx) => {
                                const p = products[ctx.dataIndex];
                                return [
                                    `Revenue: ${Utils.formatCurrency(p.revenue)}`,
                                    `Units Sold: ${Utils.formatNumber(p.units)}`,
                                    `Category: ${p.category}`,
                                ];
                            },
                        },
                    },
                },
                scales: {
                    x: {
                        grid: { color: 'rgba(255, 255, 255, 0.04)' },
                        ticks: { callback: (val) => Utils.formatCurrency(val, true) },
                    },
                    y: {
                        grid: { display: false },
                        ticks: { font: { size: 11 } },
                    },
                },
            },
        });
    }

    // ========================================================================
    // 4. STORE PERFORMANCE (Bar Chart)
    // ========================================================================
    function createStoreChart() {
        const ctx = document.getElementById('storeChart');
        if (!ctx || !data.stores) return;

        const stores = data.stores;

        charts.store = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: stores.map(s => s.name.split(' ').slice(0, 2).join(' ')),
                datasets: [{
                    label: 'Revenue',
                    data: stores.map(s => s.revenue),
                    backgroundColor: stores.map(s => {
                        const regionColors = {
                            'Northeast': '#00d4ff',
                            'Southeast': '#10b981',
                            'Midwest': '#7c3aed',
                            'Southwest': '#f59e0b',
                            'West': '#ec4899',
                        };
                        return regionColors[s.region] || '#3b82f6';
                    }),
                    borderColor: 'transparent',
                    borderRadius: 6,
                    barThickness: 32,
                }],
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            title: (items) => {
                                const idx = items[0].dataIndex;
                                return stores[idx].name;
                            },
                            label: (ctx) => {
                                const s = stores[ctx.dataIndex];
                                return [
                                    `Revenue: ${Utils.formatCurrency(s.revenue)}`,
                                    `Orders: ${Utils.formatNumber(s.transactions)}`,
                                    `Customers: ${Utils.formatNumber(s.customers)}`,
                                    `Region: ${s.region}`,
                                    `Type: ${s.type}`,
                                ];
                            },
                        },
                    },
                },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: { maxRotation: 45, font: { size: 10 } },
                    },
                    y: {
                        grid: { color: 'rgba(255, 255, 255, 0.04)' },
                        ticks: { callback: (val) => Utils.formatCurrency(val, true) },
                    },
                },
            },
        });
    }

    // ========================================================================
    // 5. CUSTOMER SEGMENTS (Polar Area Chart)
    // ========================================================================
    function createSegmentChart() {
        const ctx = document.getElementById('segmentChart');
        if (!ctx || !data.customer_segments) return;

        const segments = data.customer_segments.sort((a, b) => b.count - a.count);

        charts.segment = new Chart(ctx, {
            type: 'polarArea',
            data: {
                labels: segments.map(s => s.segment),
                datasets: [{
                    data: segments.map(s => s.count),
                    backgroundColor: segments.map((_, i) =>
                        Utils.chartColorsAlpha[i % Utils.chartColorsAlpha.length]
                    ),
                    borderColor: segments.map((_, i) =>
                        Utils.chartColors[i % Utils.chartColors.length]
                    ),
                    borderWidth: 1.5,
                }],
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'right',
                        labels: { font: { size: 10 }, padding: 8 },
                    },
                    tooltip: {
                        callbacks: {
                            label: (ctx) => {
                                const s = segments[ctx.dataIndex];
                                return [
                                    `${s.segment}: ${s.count} customers`,
                                    `Avg Spend: ${Utils.formatCurrency(s.avg_spent)}`,
                                    `Avg Orders: ${s.avg_orders}`,
                                ];
                            },
                        },
                    },
                },
                scales: {
                    r: {
                        grid: { color: 'rgba(255, 255, 255, 0.06)' },
                        ticks: { display: false },
                    },
                },
            },
        });
    }

    // ========================================================================
    // 6. PAYMENT METHODS (Bar Chart)
    // ========================================================================
    function createPaymentChart() {
        const ctx = document.getElementById('paymentChart');
        if (!ctx || !data.payment_methods) return;

        const payments = data.payment_methods;

        charts.payment = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: payments.map(p => p.method),
                datasets: [
                    {
                        label: 'Transaction Count',
                        data: payments.map(p => p.count),
                        backgroundColor: 'rgba(0, 212, 255, 0.6)',
                        borderColor: '#00d4ff',
                        borderWidth: 1,
                        borderRadius: 4,
                        yAxisID: 'y',
                    },
                    {
                        label: 'Revenue',
                        data: payments.map(p => p.revenue),
                        backgroundColor: 'rgba(124, 58, 237, 0.6)',
                        borderColor: '#7c3aed',
                        borderWidth: 1,
                        borderRadius: 4,
                        yAxisID: 'y1',
                    },
                ],
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'top', align: 'end' },
                    tooltip: {
                        callbacks: {
                            label: (ctx) => {
                                if (ctx.datasetIndex === 0) {
                                    return `Transactions: ${Utils.formatNumber(ctx.parsed.y)}`;
                                }
                                return `Revenue: ${Utils.formatCurrency(ctx.parsed.y)}`;
                            },
                        },
                    },
                },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: { font: { size: 10 } },
                    },
                    y: {
                        position: 'left',
                        grid: { color: 'rgba(255, 255, 255, 0.04)' },
                        ticks: { callback: (val) => Utils.formatNumber(val) },
                        title: { display: true, text: 'Transactions', font: { size: 10 } },
                    },
                    y1: {
                        position: 'right',
                        grid: { display: false },
                        ticks: { callback: (val) => Utils.formatCurrency(val, true) },
                        title: { display: true, text: 'Revenue', font: { size: 10 } },
                    },
                },
            },
        });
    }

    // ========================================================================
    // TOGGLE FUNCTIONS (for chart action buttons)
    // ========================================================================
    function toggleRevenueView(view) {
        if (!charts.revenue || !data.monthly_revenue) return;

        const monthly = data.monthly_revenue;
        const chart = charts.revenue;

        // Update button states
        document.querySelectorAll('#revenueChartCard .chart-action-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.view === view);
        });

        const viewConfig = {
            revenue: {
                data: monthly.map(m => m.revenue),
                maData: monthly.map(m => m.moving_avg),
                label: 'Monthly Revenue',
                maLabel: '3-Month Moving Avg',
                color: '#00d4ff',
                formatter: (val) => Utils.formatCurrency(val, true),
            },
            orders: {
                data: monthly.map(m => m.orders),
                maData: null,
                label: 'Monthly Orders',
                maLabel: null,
                color: '#7c3aed',
                formatter: (val) => Utils.formatNumber(val),
            },
            customers: {
                data: monthly.map(m => m.customers),
                maData: null,
                label: 'Unique Customers',
                maLabel: null,
                color: '#10b981',
                formatter: (val) => Utils.formatNumber(val),
            },
        };

        const config = viewConfig[view];
        const ctx = document.getElementById('revenueChart').getContext('2d');

        const gradient = ctx.createLinearGradient(0, 0, 0, 380);
        gradient.addColorStop(0, config.color.replace(')', ', 0.25)').replace('rgb', 'rgba').replace('#', ''));

        // More elegant gradient approach
        const hexToRgba = (hex, alpha) => {
            const r = parseInt(hex.slice(1, 3), 16);
            const g = parseInt(hex.slice(3, 5), 16);
            const b = parseInt(hex.slice(5, 7), 16);
            return `rgba(${r}, ${g}, ${b}, ${alpha})`;
        };

        const grad = ctx.createLinearGradient(0, 0, 0, 380);
        grad.addColorStop(0, hexToRgba(config.color, 0.25));
        grad.addColorStop(1, hexToRgba(config.color, 0.0));

        chart.data.datasets[0].data = config.data;
        chart.data.datasets[0].label = config.label;
        chart.data.datasets[0].borderColor = config.color;
        chart.data.datasets[0].backgroundColor = grad;
        chart.data.datasets[0].pointBackgroundColor = config.color;

        if (config.maData) {
            chart.data.datasets[1].data = config.maData;
            chart.data.datasets[1].label = config.maLabel;
            chart.data.datasets[1].hidden = false;
        } else {
            chart.data.datasets[1].hidden = true;
        }

        chart.options.scales.y.ticks.callback = config.formatter;
        chart.update('active');
    }

    function toggleStoreMetric(metric) {
        if (!charts.store || !data.stores) return;

        const stores = data.stores;

        document.querySelectorAll('#storeChartCard .chart-action-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.metric === metric);
        });

        if (metric === 'revenue') {
            charts.store.data.datasets[0].data = stores.map(s => s.revenue);
            charts.store.data.datasets[0].label = 'Revenue';
            charts.store.options.scales.y.ticks.callback = (val) => Utils.formatCurrency(val, true);
        } else {
            charts.store.data.datasets[0].data = stores.map(s => s.transactions);
            charts.store.data.datasets[0].label = 'Orders';
            charts.store.options.scales.y.ticks.callback = (val) => Utils.formatNumber(val);
        }

        charts.store.update('active');
    }

    return {
        init,
        toggleRevenueView,
        toggleStoreMetric,
        getChart: (name) => charts[name],
    };
})();
