from django.urls import path
from . import views
from django.contrib.auth import views as auth_views

urlpatterns = [
    path('', views.dashboard, name='dashboard'),
    path('audiencias/', views.audiencia_list, name='audiencia_list'),
    path('audiencias/<int:pk>/', views.audiencia_detail, name='audiencia_detail'),
    path('audiencias/nueva/', views.audiencia_create, name='audiencia_create'),
    path('audiencias/<int:pk>/editar/', views.audiencia_edit, name='audiencia_edit'),
    path('audiencias/<int:pk>/eliminar/', views.audiencia_delete, name='audiencia_delete'),
    path('audiencias/<int:pk>/estado/', views.audiencia_change_status, name='audiencia_change_status'),
    
    path('usuarios/', views.user_list, name='user_list'),
    path('usuarios/nuevo/', views.user_create, name='user_create'),
    path('usuarios/<int:pk>/editar/', views.user_edit, name='user_edit'),
    path('usuarios/<int:pk>/eliminar/', views.user_delete, name='user_delete'),
    
    path('login/', auth_views.LoginView.as_view(template_name='registration/login.html'), name='login'),
    path('logout/', auth_views.LogoutView.as_view(), name='logout'),
    
    path('api/login/', views.api_login, name='api_login'),
    path('api/audiencias/', views.api_audiencias, name='api_audiencias'),
    path('api/audiencias/<int:pk>/', views.api_audiencias, name='api_audiencias_detail'),
]
