document.addEventListener('DOMContentLoaded', function() {
    const grid = document.getElementById('calendarGrid');
    const title = document.getElementById('currentMonth');
    
    if (!grid || !title) {
        return;
    }

    const monthNames = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    const dayNames = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];
    
    let displayDate;
    if (window.audienciasSelectedDate) {
        const parts = window.audienciasSelectedDate.split('-');
        displayDate = new Date(parts[0], parts[1] - 1, parts[2]);
    } else {
        displayDate = new Date();
    }

    window.changeMonth = function(delta) {
        displayDate.setMonth(displayDate.getMonth() + delta);
        renderCalendar();
    };

    function renderCalendar() {
        const year = displayDate.getFullYear();
        const month = displayDate.getMonth();
        const firstDay = new Date(year, month, 1).getDay();
        const daysInMonth = new Date(year, month + 1, 0).getDate();
        const today = new Date();
        today.setHours(0,0,0,0);
        
        title.textContent = monthNames[month] + ' ' + year;
        grid.innerHTML = '';

        dayNames.forEach(function(day) {
            const cell = document.createElement('div');
            cell.className = 'calendar-day calendar-day--weekday';
            cell.textContent = day;
            grid.appendChild(cell);
        });

        for (let i = 0; i < firstDay; i++) {
            const spacer = document.createElement('div');
            spacer.className = 'calendar-day calendar-day--empty';
            grid.appendChild(spacer);
        }

        for (let day = 1; day <= daysInMonth; day++) {
            const cell = document.createElement('div');
            cell.className = 'calendar-day';
            cell.textContent = day;
            
            const cellDate = new Date(year, month, day);
            cellDate.setHours(0,0,0,0);
            const cellDateStr = cellDate.toISOString().split('T')[0];
            
            if (cellDate.getTime() === today.getTime()) {
                cell.classList.add('today');
            }
            
            if (window.audienciasCalendarDates && window.audienciasCalendarDates.includes(cellDateStr)) {
                cell.classList.add('has-event');
            }
            
            if (cellDateStr === window.audienciasSelectedDate) {
                cell.classList.add('selected');
            }
            
            cell.addEventListener('click', function() {
                window.location.href = '?date=' + cellDateStr;
            });

            grid.appendChild(cell);
        }
    }

    renderCalendar();
});
