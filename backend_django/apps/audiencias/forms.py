from django import forms
from .models import Audiencia


class AudienciaForm(forms.ModelForm):
    class Meta:
        model = Audiencia
        fields = [
            'nurej',
            'demandante',
            'demandado',
            'fecha_hora',
            'tipo_proceso',
            'tipo_audiencia',
            'sala',
            'juez',
            'estado',
            'observaciones',
            'motivo_suspension',
        ]
        widgets = {
            'nurej': forms.TextInput(attrs={'class': 'form-input', 'placeholder': 'Ingrese NUREJ'}),
            'demandante': forms.TextInput(attrs={'class': 'form-input', 'placeholder': 'Ingrese demandante'}),
            'demandado': forms.TextInput(attrs={'class': 'form-input', 'placeholder': 'Ingrese demandado'}),
            'fecha_hora': forms.DateTimeInput(attrs={'type': 'datetime-local', 'class': 'form-input'}),
            'tipo_proceso': forms.Select(attrs={'class': 'form-select'}),
            'tipo_audiencia': forms.Select(attrs={'class': 'form-select'}),
            'sala': forms.Select(attrs={'class': 'form-select'}),
            'juez': forms.Select(attrs={'class': 'form-select'}),
            'estado': forms.Select(attrs={'class': 'form-select'}),
            'observaciones': forms.Textarea(attrs={'class': 'form-textarea', 'rows': 4, 'placeholder': 'Ingrese observaciones'}),
            'motivo_suspension': forms.Select(attrs={'class': 'form-select'}),
        }
        labels = {
            'nurej': 'NUREJ',
            'demandante': 'Demandante',
            'demandado': 'Demandado',
            'fecha_hora': 'Fecha y Hora',
            'tipo_proceso': 'Tipo de Proceso',
            'tipo_audiencia': 'Tipo de Audiencia',
            'sala': 'Sala',
            'juez': 'Juez',
            'estado': 'Estado',
            'observaciones': 'Observaciones',
            'motivo_suspension': 'Motivo de Suspension',
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for field in self.fields.values():
            field.required = True
        self.fields['observaciones'].required = False
        self.fields['motivo_suspension'].required = False

    def clean(self):
        cleaned_data = super().clean()
        estado = cleaned_data.get('estado')
        motivo_suspension = cleaned_data.get('motivo_suspension')

        if estado == 'Suspendida' and not motivo_suspension:
            self.add_error('motivo_suspension', 'Seleccione un motivo de suspension')

        return cleaned_data
