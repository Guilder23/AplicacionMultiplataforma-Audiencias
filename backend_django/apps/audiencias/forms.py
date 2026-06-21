from django import forms
from .models import Audiencia
from django.contrib.auth.models import User


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
            'motivo_suspension': 'Motivo de Suspensión',
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


class UserRegistrationForm(forms.ModelForm):
    password = forms.CharField(
        label='Contraseña',
        widget=forms.PasswordInput(attrs={'class': 'form-input', 'placeholder': 'Ingrese contraseña (mínimo 8 caracteres)'}),
        min_length=8,
        required=False
    )

    class Meta:
        model = User
        fields = ['username', 'first_name', 'last_name', 'email']
        widgets = {
            'username': forms.TextInput(attrs={'class': 'form-input', 'placeholder': 'Ingrese nombre de usuario'}),
            'first_name': forms.TextInput(attrs={'class': 'form-input', 'placeholder': 'Ingrese nombre(s)'}),
            'last_name': forms.TextInput(attrs={'class': 'form-input', 'placeholder': 'Ingrese apellido(s)'}),
            'email': forms.EmailInput(attrs={'class': 'form-input', 'placeholder': 'Ingrese correo electrónico'}),
        }
        labels = {
            'username': 'Usuario',
            'first_name': 'Nombre',
            'last_name': 'Apellidos',
            'email': 'Correo Electrónico',
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if self.instance and self.instance.pk:
            # Estamos editando: contraseña es opcional
            self.fields['password'].help_text = 'Dejar en blanco para mantener la misma contraseña'
        else:
            # Estamos creando: contraseña es obligatoria
            self.fields['password'].required = True

    def save(self, commit=True):
        user = super().save(commit=False)
        password = self.cleaned_data.get('password')
        if password:
            user.set_password(password)
        if commit:
            user.save()
        return user
