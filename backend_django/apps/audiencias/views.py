from django.shortcuts import render, get_object_or_404, redirect
from django.contrib import messages
from django.utils import timezone
from django.db.models import Count, Q
from django.contrib.auth.decorators import login_required, user_passes_test
from django.contrib.auth.models import User
from django.contrib.auth import login as auth_login, authenticate
from .models import Audiencia
from .forms import AudienciaForm, UserRegistrationForm
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json


@login_required
def dashboard(request):
    now = timezone.now()
    audiencias = Audiencia.objects.all()

    summary = {
        'total': audiencias.count(),
        'programadas': audiencias.filter(estado='Programada').count(),
        'en_curso': audiencias.filter(estado='En curso').count(),
        'concluidas': audiencias.filter(estado='Concluida').count(),
        'suspendidas': audiencias.filter(estado='Suspendida').count(),
        'reprogramadas': audiencias.filter(estado='Reprogramada').count(),
    }

    proximas = audiencias.filter(
        fecha_hora__gte=now - timezone.timedelta(hours=2)
    ).order_by('fecha_hora')[:3]

    context = {
        'summary': summary,
        'proximas': proximas,
    }

    return render(request, 'audiencias/dashboard.html', context)


@login_required
def audiencia_list(request):
    query = request.GET.get('q', '')
    estado = request.GET.get('estado', '')

    audiencias = Audiencia.objects.all()

    if query:
        audiencias = audiencias.filter(
            Q(nurej__icontains=query) |
            Q(demandante__icontains=query) |
            Q(demandado__icontains=query)
        )

    if estado:
        audiencias = audiencias.filter(estado=estado)

    audiencias = audiencias.order_by('-fecha_hora')

    context = {
        'audiencias': audiencias,
        'query': query,
        'estado_actual': estado,
        'estados': Audiencia.ESTADOS,
    }

    return render(request, 'audiencias/list.html', context)


@login_required
def audiencia_detail(request, pk):
    audiencia = get_object_or_404(Audiencia, pk=pk)
    context = {'audiencia': audiencia}
    return render(request, 'audiencias/detail.html', context)


@login_required
def audiencia_create(request):
    if request.method == 'POST':
        form = AudienciaForm(request.POST)
        if form.is_valid():
            audiencia = form.save(commit=False)
            audiencia.add_to_historial(f'Audiencia registrada con estado {audiencia.estado}')
            audiencia.save()
            messages.success(request, 'Audiencia registrada correctamente')
            return redirect('audiencia_detail', pk=audiencia.pk)
    else:
        form = AudienciaForm()

    context = {'form': form, 'title': 'Nueva Audiencia'}
    return render(request, 'audiencias/form.html', context)


@login_required
def audiencia_edit(request, pk):
    audiencia = get_object_or_404(Audiencia, pk=pk)

    if request.method == 'POST':
        form = AudienciaForm(request.POST, instance=audiencia)
        if form.is_valid():
            audiencia = form.save(commit=False)
            audiencia.add_to_historial('Se actualizo la informacion de la audiencia')
            audiencia.save()
            messages.success(request, 'Audiencia actualizada correctamente')
            return redirect('audiencia_detail', pk=audiencia.pk)
    else:
        form = AudienciaForm(instance=audiencia)

    context = {'form': form, 'title': 'Editar Audiencia', 'audiencia': audiencia}
    return render(request, 'audiencias/form.html', context)


@login_required
def audiencia_delete(request, pk):
    audiencia = get_object_or_404(Audiencia, pk=pk)

    if request.method == 'POST':
        audiencia.delete()
        messages.success(request, 'Audiencia eliminada correctamente')
        return redirect('audiencia_list')

    context = {'audiencia': audiencia}
    return render(request, 'audiencias/delete_confirm.html', context)


@login_required
def audiencia_change_status(request, pk):
    audiencia = get_object_or_404(Audiencia, pk=pk)

    if request.method == 'POST':
        nuevo_estado = request.POST.get('estado')
        motivo_suspension = request.POST.get('motivo_suspension')

        if nuevo_estado in [choice[0] for choice in Audiencia.ESTADOS]:
            audiencia.estado = nuevo_estado
            if nuevo_estado == 'Suspendida':
                audiencia.motivo_suspension = motivo_suspension
                audiencia.add_to_historial(f'Estado cambiado a Suspendida. Motivo: {motivo_suspension}')
            else:
                audiencia.motivo_suspension = None
                audiencia.add_to_historial(f'Estado cambiado de {audiencia.estado} a {nuevo_estado}')
            audiencia.save()
            messages.success(request, 'Estado actualizado correctamente')

    return redirect('audiencia_detail', pk=audiencia.pk)


def is_admin(user):
    return user.is_superuser


@login_required
@user_passes_test(is_admin)
def user_list(request):
    users = User.objects.all().order_by('-date_joined')
    context = {'users': users}
    return render(request, 'audiencias/users/list.html', context)


@login_required
@user_passes_test(is_admin)
def user_create(request):
    if request.method == 'POST':
        form = UserRegistrationForm(request.POST)
        if form.is_valid():
            user = form.save()
            messages.success(request, 'Usuario creado correctamente')
            return redirect('user_list')
    else:
        form = UserRegistrationForm()

    context = {'form': form, 'title': 'Nuevo Usuario'}
    return render(request, 'audiencias/users/form.html', context)


@login_required
@user_passes_test(is_admin)
def user_edit(request, pk):
    user = get_object_or_404(User, pk=pk)

    if request.method == 'POST':
        form = UserRegistrationForm(request.POST, instance=user)
        if form.is_valid():
            user = form.save()
            messages.success(request, 'Usuario actualizado correctamente')
            return redirect('user_list')
    else:
        form = UserRegistrationForm(instance=user)

    context = {'form': form, 'title': 'Editar Usuario', 'user': user}
    return render(request, 'audiencias/users/form.html', context)


@login_required
@user_passes_test(is_admin)
def user_delete(request, pk):
    user = get_object_or_404(User, pk=pk)

    if request.method == 'POST':
        user.delete()
        messages.success(request, 'Usuario eliminado correctamente')
        return redirect('user_list')

    context = {'user': user}
    return render(request, 'audiencias/users/delete_confirm.html', context)


@csrf_exempt
def api_login(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        username = data.get('username')
        password = data.get('password')
        
        user = authenticate(username=username, password=password)
        
        if user:
            return JsonResponse({
                'success': True,
                'message': 'Inicio de sesión exitoso',
                'user': {
                    'id': user.id,
                    'username': user.username,
                    'email': user.email,
                    'first_name': user.first_name,
                    'last_name': user.last_name,
                }
            })
        else:
            return JsonResponse({
                'success': False,
                'message': 'Credenciales incorrectas'
            }, status=401)
    
    return JsonResponse({'success': False, 'message': 'Método no permitido'}, status=405)


@csrf_exempt
@login_required
def api_audiencias_list(request):
    audiencias = Audiencia.objects.all().order_by('-fecha_hora')
    data = []
    for a in audiencias:
        data.append({
            'id': a.id,
            'nurej': a.nurej,
            'demandante': a.demandante,
            'demandado': a.demandado,
            'fecha_hora': a.fecha_hora.isoformat(),
            'tipo_proceso': a.tipo_proceso,
            'tipo_audiencia': a.tipo_audiencia,
            'sala': a.sala,
            'juez': a.juez,
            'estado': a.estado,
            'observaciones': a.observaciones,
            'motivo_suspension': a.motivo_suspension,
            'historial': a.get_historial(),
        })
    return JsonResponse({'success': True, 'audiencias': data})
