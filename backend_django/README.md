# Sistema de Audiencias - Backend Django

Sistema de gestión de audiencias judiciales con interfaz web responsive, desarrollado con Django Templates.

## Características

- Dashboard con estadísticas y próximas audiencias
- CRUD completo de audiencias
- Búsqueda y filtrado por estado
- Historial de cambios de cada audiencia
- Interfaz responsive con la misma paleta de colores que la app móvil
- Integración con PostgreSQL

## Requisitos

- Python 3.8+
- PostgreSQL
- pip

## Instalación

1. Navegar al directorio del proyecto:
```bash
cd backend_django
```

2. Crear entorno virtual:
```bash
python -m venv venv
```

3. Activar entorno virtual:
- Windows:
```bash
venv\Scripts\activate
```
- Linux/Mac:
```bash
source venv/bin/activate
```

4. Instalar dependencias:
```bash
pip install -r requirements.txt
```

5. Configurar variables de entorno:
   - Editar el archivo `.env` con tus credenciales de PostgreSQL

6. Crear base de datos en PostgreSQL:
```sql
CREATE DATABASE sistema_audiencias;
```

7. Realizar migraciones:
```bash
python manage.py makemigrations
python manage.py migrate
```

8. Crear superusuario (opcional):
```bash
python manage.py createsuperuser
```

9. Ejecutar el servidor:
```bash
python manage.py runserver
```

10. Acceder a la aplicación:
    - Web: http://localhost:8000
    - Admin: http://localhost:8000/admin

## Estructura del Proyecto

```
backend_django/
├── manage.py
├── requirements.txt
├── .env
├── .gitignore
├── core/
│   ├── settings.py
│   ├── urls.py
│   ├── wsgi.py
│   └── __init__.py
├── apps/
│   ├── audiencias/
│   │   ├── models.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── forms.py
│   │   ├── admin.py
│   │   ├── apps.py
│   │   └── __init__.py
│   └── usuarios/
│       ├── apps.py
│       └── __init__.py
├── templates/
│   ├── base.html
│   └── audiencias/
│       ├── dashboard.html
│       ├── list.html
│       ├── detail.html
│       ├── form.html
│       └── delete_confirm.html
├── static/
│   ├── css/
│   │   └── style.css
│   └── js/
│       └── main.js
└── media/
```

## Paleta de Colores

- **Primario**: #B0122B (Rojo)
- **Primario Oscuro**: #6E0B1A
- **Fondo**: #F7F3F4
- **Superficie**: #FFFFFF
- **Borde**: #E8DADD
- **Texto**: #2D1B1E
- **Texto Muted**: #8D7A7E
- **Éxito**: #2E9F5F
- **Advertencia**: #F0B429
- **Peligro**: #E05A5A
- **Información**: #4C82F7
