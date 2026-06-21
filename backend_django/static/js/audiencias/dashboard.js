document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('searchInput');
    const searchResultsSection = document.getElementById('searchResultsSection');
    const searchResultsContainer = document.getElementById('searchResultsContainer');
    const mobileSearchResultsSection = document.getElementById('mobileSearchResultsSection');
    const mobileSearchResultsContainer = document.getElementById('mobileSearchResultsContainer');
    const proximasSection = document.getElementById('proximasSection');
    const mobileProximasSection = document.getElementById('mobileProximasSection');
    
    function createAudienciaCardHTML(audiencia) {
        // Parse fecha_hora (YYYY-MM-DD HH:MM)
        const dateParts = audiencia.fecha_hora.split(' ')[0].split('-');
        const timePart = audiencia.fecha_hora.split(' ')[1];
        const date = new Date(dateParts[0], dateParts[1] - 1, dateParts[2]);
        
        // Format date like "15 Jun"
        const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
        const formattedDate = date.getDate() + ' ' + months[date.getMonth()];
        const formattedTime = timePart.slice(0, 5);
        
        // Create status class
        const statusClass = 'status-' + audiencia.estado.toLowerCase().replace(/\s+/g, '-');
        
        return `
            <div class="audiencia-card dashboard-audiencia-card">
                <div class="audiencia-time">
                    <div class="time">${formattedTime}</div>
                    <div class="date">${formattedDate}</div>
                </div>
                <div class="audiencia-content">
                    <div class="audiencia-title">${audiencia.nurej}</div>
                    <div class="audiencia-subtitle">NUREJ ${audiencia.nurej}</div>
                    <div class="audiencia-parties">${audiencia.demandante} c/ ${audiencia.demandado}</div>
                    <div class="audiencia-room">${audiencia.sala || ''}</div>
                </div>
                <div class="audiencia-status ${statusClass}">
                    ${audiencia.estado}
                </div>
                <a href="${audiencia.detail_url}" class="audiencia-link"></a>
            </div>
        `;
    }
    
    function filterAudiencias(query) {
        const q = query.toLowerCase().trim();
        
        if (!q) {
            // Show proximas sections
            if (searchResultsSection) searchResultsSection.style.display = 'none';
            if (mobileSearchResultsSection) mobileSearchResultsSection.style.display = 'none';
            if (proximasSection) proximasSection.style.display = '';
            if (mobileProximasSection) mobileProximasSection.style.display = '';
            return;
        }
        
        // Filter
        const filtered = audienciasData.filter(a => 
            a.nurej.toLowerCase().includes(q) ||
            a.demandante.toLowerCase().includes(q) ||
            a.demandado.toLowerCase().includes(q) ||
            a.fecha_hora.toLowerCase().includes(q)
        );
        
        // Show search results
        if (searchResultsSection) searchResultsSection.style.display = '';
        if (mobileSearchResultsSection) mobileSearchResultsSection.style.display = '';
        if (proximasSection) proximasSection.style.display = 'none';
        if (mobileProximasSection) mobileProximasSection.style.display = 'none';
        
        // Render desktop results
        if (searchResultsContainer) {
            if (filtered.length === 0) {
                searchResultsContainer.innerHTML = `
                    <div class="empty-state">
                        <i class="fas fa-inbox"></i>
                        <h3>No se encontraron audiencias</h3>
                        <p>Prueba con otro criterio de búsqueda.</p>
                    </div>
                `;
            } else {
                searchResultsContainer.innerHTML = filtered.map(createAudienciaCardHTML).join('');
            }
        }
        
        // Render mobile results
        if (mobileSearchResultsContainer) {
            if (filtered.length === 0) {
                mobileSearchResultsContainer.innerHTML = `
                    <div class="empty-state">
                        <i class="fas fa-inbox"></i>
                        <h3>No se encontraron audiencias</h3>
                        <p>Prueba con otro criterio de búsqueda.</p>
                    </div>
                `;
            } else {
                mobileSearchResultsContainer.innerHTML = filtered.map(createAudienciaCardHTML).join('');
            }
        }
    }
    
    if (searchInput) {
        searchInput.addEventListener('input', function() {
            filterAudiencias(this.value);
        });
    }
    
    // Mini calendar code from before...
    const miniCalendar = document.getElementById('miniCalendar');
    if (miniCalendar) {
        const grid = document.getElementById('miniCalendarGrid');
        const title = document.getElementById('miniCalendarTitle');
        const prevBtn = document.getElementById('miniCalendarPrev');
        const nextBtn = document.getElementById('miniCalendarNext');
        
        const monthNames = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
        const dayNames = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];
        
        let displayDate = new Date();
        
        function renderCalendar() {
            const year = displayDate.getFullYear();
            const month = displayDate.getMonth();
            const firstDay = new Date(year, month, 1).getDay();
            const daysInMonth = new Date(year, month + 1, 0).getDate();
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            
            title.textContent = monthNames[month] + ' ' + year;
            grid.innerHTML = '';
            
            dayNames.forEach(function(day) {
                const cell = document.createElement('div');
                cell.className = 'mini-calendar-day mini-calendar-day-header';
                cell.textContent = day;
                grid.appendChild(cell);
            });
            
            for (let i = 0; i < firstDay; i++) {
                const spacer = document.createElement('div');
                spacer.className = 'mini-calendar-day mini-calendar-day-empty';
                grid.appendChild(spacer);
            }
            
            for (let day = 1; day <= daysInMonth; day++) {
                const cell = document.createElement('div');
                cell.className = 'mini-calendar-day';
                cell.textContent = day;
                
                const cellDate = new Date(year, month, day);
                cellDate.setHours(0, 0, 0, 0);
                
                if (cellDate.getTime() === today.getTime()) {
                    cell.classList.add('mini-calendar-day-today');
                }
                
                grid.appendChild(cell);
            }
        }
        
        if (prevBtn) {
            prevBtn.addEventListener('click', function() {
                displayDate.setMonth(displayDate.getMonth() - 1);
                renderCalendar();
            });
        }
        
        if (nextBtn) {
            nextBtn.addEventListener('click', function() {
                displayDate.setMonth(displayDate.getMonth() + 1);
                renderCalendar();
            });
        }
        
        renderCalendar();
    }
});
