from django.db import models
from django.utils import timezone
import json


class Audiencia(models.Model):
    ESTADOS = [
        ('Programada', 'Programada'),
        ('En curso', 'En curso'),
        ('Concluida', 'Concluida'),
        ('Suspendida', 'Suspendida'),
        ('Reprogramada', 'Reprogramada'),
    ]

    TIPOS_PROCESO = [
        ('Divorcio', 'Divorcio'),
        ('Asistencia Familiar', 'Asistencia Familiar'),
        ('Guarda', 'Guarda'),
        ('Regimen de Visitas', 'Regimen de Visitas'),
        ('Filiacion', 'Filiacion'),
    ]

    TIPOS_AUDIENCIA = [
        ('Conciliacion', 'Conciliacion'),
        ('Ratificacion', 'Ratificacion'),
        ('Seguimiento', 'Seguimiento'),
        ('Evaluacion', 'Evaluacion'),
        ('Preliminar', 'Preliminar'),
    ]

    SALAS = [
        ('Sala 1', 'Sala 1'),
        ('Sala 2', 'Sala 2'),
        ('Sala 3', 'Sala 3'),
        ('Sala Virtual', 'Sala Virtual'),
    ]

    JUECES = [
        ('Dra. Jimenez', 'Dra. Jimenez'),
        ('Dr. Perez', 'Dr. Perez'),
        ('Dra. Salazar', 'Dra. Salazar'),
        ('Dr. Quiroga', 'Dr. Quiroga'),
    ]

    MOTIVOS_SUSPENSION = [
        ('Incomparecencia', 'Incomparecencia'),
        ('Falta de notificacion', 'Falta de notificacion'),
        ('Problemas tecnicos', 'Problemas tecnicos'),
        ('Solicitud de las partes', 'Solicitud de las partes'),
    ]

    nurej = models.CharField(max_length=100, verbose_name='NUREJ')
    demandante = models.CharField(max_length=255, verbose_name='Demandante')
    demandado = models.CharField(max_length=255, verbose_name='Demandado')
    fecha_hora = models.DateTimeField(verbose_name='Fecha y Hora')
    tipo_proceso = models.CharField(max_length=100, choices=TIPOS_PROCESO, verbose_name='Tipo de Proceso')
    tipo_audiencia = models.CharField(max_length=100, choices=TIPOS_AUDIENCIA, verbose_name='Tipo de Audiencia')
    sala = models.CharField(max_length=100, choices=SALAS, verbose_name='Sala')
    juez = models.CharField(max_length=100, choices=JUECES, verbose_name='Juez')
    estado = models.CharField(max_length=100, choices=ESTADOS, default='Programada', verbose_name='Estado')
    observaciones = models.TextField(blank=True, verbose_name='Observaciones')
    motivo_suspension = models.CharField(max_length=255, blank=True, null=True, choices=MOTIVOS_SUSPENSION, verbose_name='Motivo de Suspension')
    historial = models.TextField(default='[]', verbose_name='Historial')
    fecha_creacion = models.DateTimeField(auto_now_add=True, verbose_name='Fecha de Creacion')
    fecha_actualizacion = models.DateTimeField(auto_now=True, verbose_name='Fecha de Actualizacion')

    class Meta:
        verbose_name = 'Audiencia'
        verbose_name_plural = 'Audiencias'
        ordering = ['-fecha_hora']

    def __str__(self):
        return f'{self.tipo_proceso} - {self.nurej}'

    def get_historial(self):
        try:
            return json.loads(self.historial)
        except json.JSONDecodeError:
            return []

    def set_historial(self, historial):
        self.historial = json.dumps(historial, ensure_ascii=False)

    def add_to_historial(self, mensaje):
        historial = self.get_historial()
        timestamp = timezone.localtime(timezone.now()).strftime('%d/%m/%Y %H:%M')
        historial.append(f'{timestamp} - {mensaje}')
        self.set_historial(historial)
