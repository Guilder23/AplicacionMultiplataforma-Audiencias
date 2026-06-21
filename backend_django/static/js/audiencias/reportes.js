document.addEventListener('DOMContentLoaded', function() {
    const colors = ['#B0122B', '#4A90E2', '#FFA500', '#50C878', '#9B59B6'];

    // Pie Chart
    const pieCtx = document.getElementById('pieChart');
    if (pieCtx && typeof summaryByProcess !== 'undefined' && summaryByProcess.length > 0) {
        const labels = summaryByProcess.map(item => item.tipo_proceso);
        const data = summaryByProcess.map(item => item.count);

        new Chart(pieCtx, {
            type: 'pie',
            data: {
                labels: labels,
                datasets: [{
                    data: data,
                    backgroundColor: colors.slice(0, labels.length),
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: {
                        display: false
                    }
                }
            }
        });

        // Update legend colors
        const legendItems = document.querySelectorAll('#pieChartLegend .legend-item');
        legendItems.forEach((item, index) => {
            const colorDiv = item.querySelector('.legend-color');
            if (colorDiv) {
                colorDiv.style.backgroundColor = colors[index % colors.length];
            }
        });
    }

    // Bar Chart
    const barCtx = document.getElementById('barChart');
    if (barCtx && typeof summaryByStatus !== 'undefined') {
        const labels = ['Programada', 'En curso', 'Concluida', 'Suspendida', 'Reprogramada'];
        const data = [
            summaryByStatus.Programada || 0,
            summaryByStatus['En curso'] || 0,
            summaryByStatus.Concluida || 0,
            summaryByStatus.Suspendida || 0,
            summaryByStatus.Reprogramada || 0
        ];
        const bgColors = ['#B0122B', '#4A90E2', '#50C878', '#FFA500', '#9B59B6'];

        new Chart(barCtx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Audiencias',
                    data: data,
                    backgroundColor: bgColors,
                    borderRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {
                            display: false
                        }
                    },
                    x: {
                        grid: {
                            display: false
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: false
                    }
                }
            }
        });
    }
});
