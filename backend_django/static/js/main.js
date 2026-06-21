document.addEventListener('DOMContentLoaded', function() {
    const notificationsToggle = document.getElementById('notificationsToggle');
    const notificationsPanel = document.getElementById('notificationsPanel');

    if (notificationsToggle && notificationsPanel) {
        notificationsToggle.addEventListener('click', function(event) {
            event.stopPropagation();
            notificationsPanel.classList.toggle('active');
        });

        document.addEventListener('click', function() {
            notificationsPanel.classList.remove('active');
        });

        notificationsPanel.addEventListener('click', function(event) {
            event.stopPropagation();
        });
    }
});
