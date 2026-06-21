document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('searchInput');
    const desktopRows = document.querySelectorAll('.audiencia-row');
    const mobileCards = document.querySelectorAll('.audiencia-mobile-card');
    const desktopCountEl = document.getElementById('desktopCount');
    
    function filterAudiencias(query) {
        const q = query.toLowerCase().trim();
        let visibleCount = 0;
        
        // Filter desktop rows
        desktopRows.forEach(row => {
            const audienciaId = row.dataset.audienciaId;
            const audiencia = audienciasData.find(a => a.id == audienciaId);
            if (!audiencia) return;
            
            const match = 
                audiencia.nurej.toLowerCase().includes(q) ||
                audiencia.demandante.toLowerCase().includes(q) ||
                audiencia.demandado.toLowerCase().includes(q) ||
                audiencia.fecha_hora.toLowerCase().includes(q);
                
            row.style.display = match ? '' : 'none';
            if (match) visibleCount++;
        });
        
        // Filter mobile cards
        mobileCards.forEach(card => {
            const audienciaId = card.dataset.audienciaId;
            const audiencia = audienciasData.find(a => a.id == audienciaId);
            if (!audiencia) return;
            
            const match = 
                audiencia.nurej.toLowerCase().includes(q) ||
                audiencia.demandante.toLowerCase().includes(q) ||
                audiencia.demandado.toLowerCase().includes(q) ||
                audiencia.fecha_hora.toLowerCase().includes(q);
                
            card.style.display = match ? '' : 'none';
        });
        
        // Update count
        if (desktopCountEl) {
            desktopCountEl.textContent = visibleCount;
        }
    }
    
    if (searchInput) {
        searchInput.addEventListener('input', function() {
            filterAudiencias(this.value);
        });
    }
});
