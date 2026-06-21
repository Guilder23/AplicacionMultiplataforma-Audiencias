document.addEventListener(''DOMContentLoaded'', () => {
    const searchInput = document.getElementById(''searchInput'');
    if (!searchInput) {
        return;
    }

    searchInput.addEventListener(''keypress'', (event) => {
        if (event.key !== ''Enter'') {
            return;
        }
        const currentUrl = new URL(window.location.href);
        const query = searchInput.value.trim();
        if (query) {
            currentUrl.searchParams.set(''q'', query);
        } else {
            currentUrl.searchParams.delete(''q'');
        }
        window.location.href = currentUrl.toString();
    });
});
