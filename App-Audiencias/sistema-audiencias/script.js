let audiencias =
JSON.parse(localStorage.getItem("audiencias")) || [];

const tabla = document.getElementById("tablaAudiencias");
const mobileList = document.getElementById("mobileList");
const modal = document.getElementById("modal");
const form = document.getElementById("formAudiencia");
const btnNueva = document.getElementById("btnNueva");
const cerrar = document.getElementById("cerrar");
const buscar = document.getElementById("buscar");

function abrirModal() {
    form.reset();
    document.getElementById("id").value = "";
    modal.style.display = "flex";
    document.body.classList.add("modal-open");
}

function cerrarModal() {
    modal.style.display = "none";
    document.body.classList.remove("modal-open");
}

btnNueva.onclick = abrirModal;

cerrar.onclick = cerrarModal;

modal.addEventListener("click", (e) => {
    if (e.target === modal) {
        cerrarModal();
    }
});

document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && modal.style.display === "flex") {
        cerrarModal();
    }
});

form.addEventListener("submit", (e) => {
    e.preventDefault();

    const audiencia = {
        id: document.getElementById("id").value || Date.now(),
        nurej: document.getElementById("nurej").value,
        demandante: document.getElementById("demandante").value,
        demandado: document.getElementById("demandado").value,
        proceso: document.getElementById("proceso").value,
        fecha: document.getElementById("fecha").value,
        estado: document.getElementById("estado").value
    };

    const index = audiencias.findIndex(
        a => a.id == audiencia.id
    );

    if (index >= 0) {
        audiencias[index] = audiencia;
    } else {
        audiencias.push(audiencia);
    }

    guardar();
    cerrarModal();
});

function guardar() {
    localStorage.setItem(
        "audiencias",
        JSON.stringify(audiencias)
    );

    listar();
}

function listar() {
    tabla.innerHTML = "";
    mobileList.innerHTML = "";

    let texto = buscar.value.toLowerCase();

    let filtrados = audiencias.filter(a =>
        a.nurej.toLowerCase().includes(texto) ||
        a.demandante.toLowerCase().includes(texto) ||
        a.demandado.toLowerCase().includes(texto) ||
        a.proceso.toLowerCase().includes(texto)
    );

    filtrados.forEach(a => {
        tabla.innerHTML += `
            <tr>
                <td>${a.nurej}</td>
                <td>${a.demandante}</td>
                <td>${a.demandado}</td>
                <td>${a.proceso}</td>
                <td>${a.fecha}</td>
                <td>${a.estado}</td>
                <td class="acciones">
                    <button class="editar" onclick="editar('${a.id}')">
                        <i class="fa-solid fa-pen-to-square"></i>
                    </button>
                    <button class="eliminar" onclick="eliminarAudiencia('${a.id}')">
                        <i class="fa-solid fa-trash"></i>
                    </button>
                </td>
            </tr>
        `;

        mobileList.innerHTML += `
            <div class="mobile-card">
                <div class="mobile-card-head">
                    <span class="mobile-tag">${a.nurej}</span>
                    <span class="mobile-state">${a.estado}</span>
                </div>
                <div class="mobile-card-body">
                    <p><i class="fa-solid fa-user"></i> <strong>Demandante:</strong> ${a.demandante}</p>
                    <p><i class="fa-solid fa-user-shield"></i> <strong>Demandado:</strong> ${a.demandado}</p>
                    <p><i class="fa-solid fa-file-contract"></i> <strong>Proceso:</strong> ${a.proceso}</p>
                    <p><i class="fa-solid fa-calendar-day"></i> <strong>Fecha:</strong> ${a.fecha}</p>
                </div>
                <div class="mobile-actions">
                    <button class="editar" onclick="editar('${a.id}')">
                        <i class="fa-solid fa-pen-to-square"></i> Editar
                    </button>
                    <button class="eliminar" onclick="eliminarAudiencia('${a.id}')">
                        <i class="fa-solid fa-trash"></i> Eliminar
                    </button>
                </div>
            </div>
        `;
    });

    estadisticas();
}

function editar(id) {
    const a = audiencias.find(x => x.id == id);

    document.getElementById("id").value = a.id;
    document.getElementById("nurej").value = a.nurej;
    document.getElementById("demandante").value = a.demandante;
    document.getElementById("demandado").value = a.demandado;
    document.getElementById("proceso").value = a.proceso;
    document.getElementById("fecha").value = a.fecha;
    document.getElementById("estado").value = a.estado;

    modal.style.display = "flex";
    document.body.classList.add("modal-open");
}

function eliminarAudiencia(id) {
    if (confirm("¿Eliminar audiencia?")) {
        audiencias = audiencias.filter(
            a => a.id != id
        );

        guardar();
    }
}

function estadisticas() {
    document.getElementById("total").textContent =
        audiencias.length;

    document.getElementById("programadas").textContent =
        audiencias.filter(
            a => a.estado === "Programada"
        ).length;

    document.getElementById("concluidas").textContent =
        audiencias.filter(
            a => a.estado === "Concluida"
        ).length;
}

buscar.addEventListener("keyup", listar);

listar();