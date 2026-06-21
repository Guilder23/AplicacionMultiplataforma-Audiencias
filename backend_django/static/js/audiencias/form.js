document.addEventListener(''DOMContentLoaded'', () => {
    const estadoSelect = document.querySelector(''select[name="estado"]'');
    const motivoGroup = document.getElementById(''motivoSuspensionGroup'');

    if (!estadoSelect || !motivoGroup) {
        return;
    }

    const toggleMotivoSuspension = () => {
        motivoGroup.style.display = estadoSelect.value === ''Suspendida'' ? ''block'' : ''none'';
    };

    estadoSelect.addEventListener(''change'', toggleMotivoSuspension);
    toggleMotivoSuspension();
});
