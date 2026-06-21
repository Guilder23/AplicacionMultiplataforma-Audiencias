document.addEventListener(''DOMContentLoaded'', () => {
    const dropdownBtn = document.getElementById(''dropdownBtn'');
    const dropdownMenu = document.getElementById(''dropdownMenu'');
    const statusModal = document.getElementById(''statusModal'');
    const changeStatusBtn = document.getElementById(''changeStatusBtn'');
    const changeStatusBtnBottom = document.getElementById(''changeStatusBtnBottom'');
    const closeModal = document.getElementById(''closeModal'');
    const estadoSelect = document.getElementById(''estado'');
    const motivoSuspensionGroup = document.getElementById(''motivoSuspensionGroup'');

    if (dropdownBtn && dropdownMenu) {
        dropdownBtn.addEventListener(''click'', () => {
            dropdownMenu.classList.toggle(''show'');
        });

        document.addEventListener(''click'', (event) => {
            if (!dropdownBtn.contains(event.target) && !dropdownMenu.contains(event.target)) {
                dropdownMenu.classList.remove(''show'');
            }
        });
    }

    if (statusModal && changeStatusBtn && changeStatusBtnBottom && closeModal && estadoSelect && motivoSuspensionGroup) {
        const openModal = () => statusModal.classList.add(''show'');
        const closeModalFn = () => statusModal.classList.remove(''show'');
        const toggleMotivo = () => {
            motivoSuspensionGroup.style.display = estadoSelect.value === ''Suspendida'' ? ''block'' : ''none'';
        };

        changeStatusBtn.addEventListener(''click'', openModal);
        changeStatusBtnBottom.addEventListener(''click'', openModal);
        closeModal.addEventListener(''click'', closeModalFn);
        statusModal.addEventListener(''click'', (event) => {
            if (event.target === statusModal) {
                closeModalFn();
            }
        });
        estadoSelect.addEventListener(''change'', toggleMotivo);
        toggleMotivo();
    }
});
