/**
 * Retail Sales Analytics Dashboard — Main Application Module
 * Handles data loading, global state management, and initialization.
 */

const App = (() => {
    // Global state
    let analyticsData = null;
    let isLoaded = false;

    /**
     * Initialize the dashboard application
     */
    async function init() {
        try {
            // Load analytics data
            analyticsData = await loadData();
            isLoaded = true;

            // Initialize all modules
            KPICards.init(analyticsData);
            Charts.init(analyticsData);
            DataTables.init(analyticsData);
            Filters.init(analyticsData);

            // Update header info
            updateDataFreshness();

            // Hide loading overlay
            hideLoading();

            console.log('✅ Dashboard initialized successfully');
        } catch (error) {
            console.error('❌ Failed to initialize dashboard:', error);
            showError(error.message);
        }
    }

    /**
     * Load analytics data from JSON file
     */
    async function loadData() {
        try {
            const response = await fetch('data/analytics_data.json');
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            const data = await response.json();
            console.log('📊 Data loaded:', {
                months: data.monthly_revenue?.length,
                categories: data.categories?.length,
                products: data.top_products?.length,
                stores: data.stores?.length,
                segments: data.customer_segments?.length,
            });
            return data;
        } catch (error) {
            console.warn('⚠️ Could not load JSON file, using embedded fallback data');
            throw error;
        }
    }

    /**
     * Update the data freshness indicator in the header
     */
    function updateDataFreshness() {
        const el = document.getElementById('dataFreshness');
        if (el && analyticsData?.generated_at) {
            const date = new Date(analyticsData.generated_at);
            const formatted = date.toLocaleDateString('en-US', {
                month: 'short', day: 'numeric', year: 'numeric',
                hour: '2-digit', minute: '2-digit',
            });
            el.textContent = `Updated: ${formatted}`;
        } else if (el) {
            el.textContent = 'Live Data';
        }
    }

    /**
     * Hide the loading overlay with a smooth transition
     */
    function hideLoading() {
        const overlay = document.getElementById('loadingOverlay');
        if (overlay) {
            overlay.classList.add('hidden');
            setTimeout(() => overlay.remove(), 500);
        }
    }

    /**
     * Show an error message
     */
    function showError(message) {
        const overlay = document.getElementById('loadingOverlay');
        if (overlay) {
            overlay.innerHTML = `
                <div style="text-align: center; max-width: 500px; padding: 32px;">
                    <div style="font-size: 48px; margin-bottom: 16px;">⚠️</div>
                    <h2 style="color: #f1f5f9; margin-bottom: 12px;">Data Load Error</h2>
                    <p style="color: #94a3b8; margin-bottom: 24px;">
                        Could not load analytics data. Please run the Python pipeline first:
                    </p>
                    <code style="background: rgba(255,255,255,0.1); padding: 12px 20px; border-radius: 8px; color: #00d4ff; font-family: 'JetBrains Mono', monospace; display: block;">
                        cd python && python main.py
                    </code>
                    <p style="color: #64748b; margin-top: 16px; font-size: 12px;">
                        Error: ${message}
                    </p>
                </div>
            `;
        }
    }

    // Public API
    return {
        init,
        getData: () => analyticsData,
        isLoaded: () => isLoaded,
    };
})();

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

const Utils = {
    /**
     * Format a number as currency
     */
    formatCurrency(value, compact = false) {
        if (compact && Math.abs(value) >= 1000000) {
            return '$' + (value / 1000000).toFixed(1) + 'M';
        }
        if (compact && Math.abs(value) >= 1000) {
            return '$' + (value / 1000).toFixed(1) + 'K';
        }
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0,
        }).format(value);
    },

    /**
     * Format a number with comma separators
     */
    formatNumber(value) {
        return new Intl.NumberFormat('en-US').format(Math.round(value));
    },

    /**
     * Format a percentage
     */
    formatPercent(value, decimals = 1) {
        return value.toFixed(decimals) + '%';
    },

    /**
     * Get a CSS class for a category badge
     */
    getCategoryBadgeClass(category) {
        const map = {
            'Electronics': 'badge-electronics',
            'Clothing': 'badge-clothing',
            'Home & Garden': 'badge-home',
            'Sports & Fitness': 'badge-sports',
            'Beauty': 'badge-beauty',
            'Books & Media': 'badge-books',
            'Food & Beverages': 'badge-food',
            'Toys & Games': 'badge-toys',
        };
        return map[category] || 'badge-electronics';
    },

    /**
     * Get a rank badge class
     */
    getRankBadgeClass(rank) {
        if (rank === 1) return 'rank-1';
        if (rank === 2) return 'rank-2';
        if (rank === 3) return 'rank-3';
        return 'rank-default';
    },

    /**
     * Animate a number counting up
     */
    animateValue(element, start, end, duration, formatter) {
        const startTime = performance.now();

        function update(currentTime) {
            const elapsed = currentTime - startTime;
            const progress = Math.min(elapsed / duration, 1);
            // Ease-out cubic
            const eased = 1 - Math.pow(1 - progress, 3);
            const current = start + (end - start) * eased;

            element.textContent = formatter(current);

            if (progress < 1) {
                requestAnimationFrame(update);
            }
        }

        requestAnimationFrame(update);
    },

    /**
     * Chart.js color palette
     */
    chartColors: [
        '#00d4ff', '#7c3aed', '#10b981', '#f59e0b',
        '#ec4899', '#3b82f6', '#14b8a6', '#ef4444',
        '#8b5cf6', '#06b6d4', '#f97316', '#84cc16',
    ],

    chartColorsAlpha: [
        'rgba(0, 212, 255, 0.2)', 'rgba(124, 58, 237, 0.2)',
        'rgba(16, 185, 129, 0.2)', 'rgba(245, 158, 11, 0.2)',
        'rgba(236, 72, 153, 0.2)', 'rgba(59, 130, 246, 0.2)',
        'rgba(20, 184, 166, 0.2)', 'rgba(239, 68, 68, 0.2)',
        'rgba(139, 92, 246, 0.2)', 'rgba(6, 182, 212, 0.2)',
        'rgba(249, 115, 22, 0.2)', 'rgba(132, 204, 22, 0.2)',
    ],
};

// ============================================================================
// INITIALIZE ON DOM LOAD
// ============================================================================
document.addEventListener('DOMContentLoaded', () => {
    App.init();
});
