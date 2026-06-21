document.addEventListener(''DOMContentLoaded'', () => {
    const grid = document.getElementById(''miniCalendarGrid'');
    const title = document.getElementById(''miniCalendarTitle'');
    const prev = document.getElementById(''miniCalendarPrev'');
    const next = document.getElementById(''miniCalendarNext'');

    if (!grid || !title || !prev || !next) {
        return;
    }

    const monthNames = [''Enero'', ''Febrero'', ''Marzo'', ''Abril'', ''Mayo'', ''Junio'', ''Julio'', ''Agosto'', ''Septiembre'', ''Octubre'', ''Noviembre'', ''Diciembre''];
    const dayNames = [''D'', ''L'', ''M'', ''M'', ''J'', ''V'', ''S''];
    let displayDate = new Date();
    const selectedDate = new Date();

    function renderCalendar() {
        const year = displayDate.getFullYear();
        const month = displayDate.getMonth();
        const firstDay = new Date(year, month, 1).getDay();
        const daysInMonth = new Date(year, month + 1, 0).getDate();
        const today = new Date();

        title.textContent = `${monthNames[month]} ${year}`;
        grid.innerHTML = '''';

        dayNames.forEach((day) => {
            const cell = document.createElement(''div'');
            cell.className = ''mini-calendar-weekday'';
            cell.textContent = day;
            grid.appendChild(cell);
        });

        for (let i = 0; i < firstDay; i += 1) {
            const spacer = document.createElement(''div'');
            spacer.className = ''mini-calendar-day mini-calendar-day--empty'';
            grid.appendChild(spacer);
        }

        for (let day = 1; day <= daysInMonth; day += 1) {
            const cell = document.createElement(''div'');
            cell.className = ''mini-calendar-day'';
            cell.textContent = day;

            if (day === today.getDate() && month === today.getMonth() && year === today.getFullYear()) {
                cell.classList.add(''is-today'');
            }

            if (day === selectedDate.getDate() && month === selectedDate.getMonth() && year === selectedDate.getFullYear()) {
                cell.classList.add(''is-selected'');
            }

            grid.appendChild(cell);
        }
    }

    prev.addEventListener(''click'', () => {
        displayDate.setMonth(displayDate.getMonth() - 1);
        renderCalendar();
    });

    next.addEventListener(''click'', () => {
        displayDate.setMonth(displayDate.getMonth() + 1);
        renderCalendar();
    });

    renderCalendar();
});
