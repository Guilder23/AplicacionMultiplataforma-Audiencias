from django.urls import path
from . import views

urlpatterns = [
    path('', views.dashboard, name='dashboard'),
    path('audiencias/', views.audiencia_list, name='audiencia_list'),
    path('audiencias/<int:pk>/', views.audiencia_detail, name='audiencia_detail'),
    path('audiencias/nueva/', views.audiencia_create, name='audiencia_create'),
    path('audiencias/<int:pk>/editar/', views.audiencia_edit, name='audiencia_edit'),
    path('audiencias/<int:pk>/eliminar/', views.audiencia_delete, name='audiencia_delete'),
    path('audiencias/<int:pk>/estado/', views.audiencia_change_status, name='audiencia_change_status'),
]
