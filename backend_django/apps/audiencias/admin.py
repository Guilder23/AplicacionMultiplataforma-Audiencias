from django.contrib import admin
from .models import Audiencia, Anuncio


@admin.register(Anuncio)
class AnuncioAdmin(admin.ModelAdmin):
    list_display = ['titulo', 'prioridad', 'activo', 'publicado_por', 'fecha_publicacion']
    list_filter = ['activo', 'prioridad', 'fecha_publicacion']
    search_fields = ['titulo', 'mensaje']
    readonly_fields = ['fecha_creacion', 'fecha_actualizacion']


@admin.register(Audiencia)
class AudienciaAdmin(admin.ModelAdmin):
    list_display = [
        'nurej',
        'tipo_proceso',
        'demandante',
        'demandado',
        'fecha_hora',
        'estado',
        'juez',
    ]
    list_filter = [
        'estado',
        'tipo_proceso',
        'juez',
        'sala',
        'fecha_creacion',
    ]
    search_fields = [
        'nurej',
        'demandante',
        'demandado',
        'observaciones',
    ]
    date_hierarchy = 'fecha_hora'
    readonly_fields = [
        'fecha_creacion',
        'fecha_actualizacion',
        'historial',
    ]
    fieldsets = [
        (
            'Informacion General',
            {
                'fields': [
                    'nurej',
                    'tipo_proceso',
                    'tipo_audiencia',
                    'fecha_hora',
                    'sala',
                    'juez',
                    'estado',
                ]
            }
        ),
        (
            'Partes',
            {
                'fields': [
                    'demandante',
                    'demandado',
                ]
            }
        ),
        (
            'Detalles',
            {
                'fields': [
                    'observaciones',
                    'motivo_suspension',
                ]
            }
        ),
        (
            'Sistema',
            {
                'fields': [
                    'historial',
                    'fecha_creacion',
                    'fecha_actualizacion',
                ],
                'classes': ['collapse'],
            }
        ),
    ]
