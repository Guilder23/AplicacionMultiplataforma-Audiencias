from django.shortcuts import render, get_object_or_404, redirect, reverse
from django.contrib import messages
from django.utils import timezone
from django.db.models import Count, Q
from django.contrib.auth.decorators import login_required, user_passes_test
from django.contrib.auth.models import User
from django.contrib.auth import login as auth_login, authenticate, logout as auth_logout
from django.core import signing
from django.utils.safestring import mark_safe
from .models import Audiencia, Anuncio
from .forms import AudienciaForm, UserRegistrationForm
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json


API_TOKEN_SALT = 'apps.audiencias.api'
API_TOKEN_MAX_AGE = 60 * 60 * 24 * 7


def _create_api_token(user):
    return signing.dumps({'user_id': user.pk}, salt=API_TOKEN_SALT)


def _get_api_user(request):
    if request.user.is_authenticated:
        return request.user

    auth_header = request.headers.get('Authorization', '')
    token = None

    if auth_header.startswith('Bearer '):
        token = auth_header[7:].strip()
    else:
        token = request.headers.get('X-Auth-Token')

    if not token:
        return None

    try:
        payload = signing.loads(
            token,
            salt=API_TOKEN_SALT,
            max_age=API_TOKEN_MAX_AGE,
        )
    except (signing.BadSignature, signing.SignatureExpired):
        return None

    user_id = payload.get('user_id')
    if not user_id:
        return None

    try:
        return User.objects.get(pk=user_id, is_active=True)
    except User.DoesNotExist:
        return None


def _parse_json_body(request):
    try:
        return json.loads(request.body or '{}')
    except json.JSONDecodeError:
        return None


def _serialize_audiencia(audiencia, include_historial=False):
    data = {
        'id': audiencia.id,
        'nurej': audiencia.nurej,
        'demandante': audiencia.demandante,
        'demandado': audiencia.demandado,
        'fecha_hora': audiencia.fecha_hora.isoformat(),
        'tipo_proceso': audiencia.tipo_proceso,
        'tipo_audiencia': audiencia.tipo_audiencia,
        'sala': audiencia.sala,
        'juez': audiencia.juez,
        'estado': audiencia.estado,
        'observaciones': audiencia.observaciones,
        'motivo_suspension': audiencia.motivo_suspension,
    }

    if include_historial:
        data['historial'] = audiencia.get_historial()

    return data


def is_admin(user):
    return user.is_superuser


@login_required
def dashboard(request):
    now = timezone.now()
    # Solo las audiencias del usuario actual
    audiencias = Audiencia.objects.filter(usuario=request.user)
    anuncios_queryset = Anuncio.objects.filter(activo=True).order_by('-fecha_publicacion')
    anuncios_preview = anuncios_queryset[:3]
    ultima_anuncio = anuncios_queryset.first()

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
    
    # Convert all audiencias to JSON for search
    audiencias_json = []
    for a in audiencias:
        audiencias_json.append({
            'id': a.id,
            'nurej': a.nurej,
            'demandante': a.demandante,
            'demandado': a.demandado,
            'estado': a.estado,
            'fecha_hora': a.fecha_hora.strftime('%Y-%m-%d %H:%M'),
            'sala': a.sala,
            'detail_url': reverse('audiencia_detail', args=[a.id])
        })

    context = {
        'summary': summary,
        'proximas': proximas,
        'anuncios_preview': anuncios_preview,
        'ultima_anuncio': ultima_anuncio,
        'anuncios_count': anuncios_queryset.count(),
        'is_admin': request.user.is_superuser,
        'audiencias_json': mark_safe(json.dumps(audiencias_json, ensure_ascii=False))
    }

    return render(request, 'audiencias/dashboard.html', context)


@login_required
def notificaciones(request):
    anuncios = Anuncio.objects.filter(activo=True).order_by('-fecha_publicacion')
    context = {
        'anuncios': anuncios,
        'anuncios_count': anuncios.count(),
        'is_admin': request.user.is_superuser,
    }
    return render(request, 'audiencias/notificaciones.html', context)


@login_required
@user_passes_test(is_admin)
def anuncio_create(request):
    if request.method == 'POST':
        titulo = (request.POST.get('titulo') or '').strip()
        mensaje = (request.POST.get('mensaje') or '').strip()
        prioridad = request.POST.get('prioridad', 'normal')
        activo = request.POST.get('activo') == 'on'

        if titulo and mensaje:
            Anuncio.objects.create(
                titulo=titulo,
                mensaje=mensaje,
                prioridad=prioridad,
                activo=activo,
                publicado_por=request.user,
            )
            messages.success(request, 'Anuncio publicado correctamente')
        else:
            messages.error(request, 'Completa el título y el mensaje para publicar')

    return redirect('dashboard')


@login_required
@user_passes_test(is_admin)
def anuncio_edit(request, pk):
    anuncio = get_object_or_404(Anuncio, pk=pk)
    if request.method == 'POST':
        titulo = (request.POST.get('titulo') or '').strip()
        mensaje = (request.POST.get('mensaje') or '').strip()
        prioridad = request.POST.get('prioridad', 'normal')
        activo = request.POST.get('activo') == 'on'
        if titulo and mensaje:
            anuncio.titulo = titulo
            anuncio.mensaje = mensaje
            anuncio.prioridad = prioridad
            anuncio.activo = activo
            anuncio.save()
            messages.success(request, 'Anuncio actualizado correctamente')
        else:
            messages.error(request, 'Completa el título y el mensaje para actualizar')
    return redirect('notificaciones')


@login_required
@user_passes_test(is_admin)
def anuncio_delete(request, pk):
    anuncio = get_object_or_404(Anuncio, pk=pk)
    if request.method == 'POST':
        anuncio.delete()
        messages.success(request, 'Anuncio eliminado correctamente')
    return redirect('notificaciones')


@login_required
def calendario(request):
    from datetime import datetime
    date_str = request.GET.get('date', datetime.now().strftime('%Y-%m-%d'))
    selected_date = datetime.strptime(date_str, '%Y-%m-%d').date()
    
    # Solo las audiencias del usuario actual
    audiencias = Audiencia.objects.filter(
        usuario=request.user,
        fecha_hora__date=selected_date
    ).order_by('fecha_hora')
    
    # Obtener todas las fechas con audiencias para marcarlas en el calendario
    all_dates = Audiencia.objects.filter(usuario=request.user).dates('fecha_hora', 'day')
    
    context = {
        'audiencias': audiencias,
        'selected_date': selected_date,
        'all_dates': [d.strftime('%Y-%m-%d') for d in all_dates],
    }
    
    return render(request, 'audiencias/calendario.html', context)


@login_required
def reportes(request):
    from django.db.models import Count
    # Solo las audiencias del usuario actual
    audiencias = Audiencia.objects.filter(usuario=request.user)
    
    # Resumen por estado
    summary_by_status = {
        'Total': audiencias.count(),
        'Programada': audiencias.filter(estado='Programada').count(),
        'En curso': audiencias.filter(estado='En curso').count(),
        'Concluida': audiencias.filter(estado='Concluida').count(),
        'Suspendida': audiencias.filter(estado='Suspendida').count(),
        'Reprogramada': audiencias.filter(estado='Reprogramada').count(),
    }
    
    # Resumen por tipo de proceso
    summary_by_process = audiencias.values('tipo_proceso').annotate(count=Count('id')).order_by('-count')
    
    context = {
        'summary_by_status': summary_by_status,
        'summary_by_process': summary_by_process,
        'summary_by_status_json': mark_safe(json.dumps(summary_by_status, ensure_ascii=False)),
        'summary_by_process_json': mark_safe(json.dumps(list(summary_by_process), ensure_ascii=False)),
    }
    
    return render(request, 'audiencias/reportes.html', context)


@login_required
def audiencia_list(request):
    query = request.GET.get('q', '')
    estado = request.GET.get('estado', '')

    audiencias = Audiencia.objects.filter(usuario=request.user)

    if query:
        audiencias = audiencias.filter(
            Q(nurej__icontains=query) |
            Q(demandante__icontains=query) |
            Q(demandado__icontains=query)
        )

    if estado:
        audiencias = audiencias.filter(estado=estado)

    audiencias = audiencias.order_by('-fecha_hora')
    
    # Convert to JSON for JS
    audiencias_json = []
    for a in audiencias:
        audiencias_json.append({
            'id': a.id,
            'nurej': a.nurej,
            'demandante': a.demandante,
            'demandado': a.demandado,
            'estado': a.estado,
            'fecha_hora': a.fecha_hora.strftime('%Y-%m-%d %H:%M'),
            'sala': a.sala,
            'detail_url': reverse('audiencia_detail', args=[a.id])
        })

    context = {
        'audiencias': audiencias,
        'audiencias_json': mark_safe(json.dumps(audiencias_json, ensure_ascii=False)),
        'query': query,
        'estado_actual': estado,
        'estados': Audiencia.ESTADOS,
    }

    return render(request, 'audiencias/list.html', context)


@login_required
def audiencia_detail(request, pk):
    audiencia = get_object_or_404(Audiencia, pk=pk, usuario=request.user)
    context = {'audiencia': audiencia}
    return render(request, 'audiencias/detail.html', context)


@login_required
def audiencia_create(request):
    if request.method == 'POST':
        form = AudienciaForm(request.POST)
        if form.is_valid():
            audiencia = form.save(commit=False)
            audiencia.usuario = request.user
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
    audiencia = get_object_or_404(Audiencia, pk=pk, usuario=request.user)

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
    audiencia = get_object_or_404(Audiencia, pk=pk, usuario=request.user)

    if request.method == 'POST':
        audiencia.delete()
        messages.success(request, 'Audiencia eliminada correctamente')
        return redirect('audiencia_list')

    context = {'audiencia': audiencia}
    return render(request, 'audiencias/delete_confirm.html', context)


@login_required
def audiencia_change_status(request, pk):
    audiencia = get_object_or_404(Audiencia, pk=pk, usuario=request.user)

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


def logout_view(request):
    auth_logout(request)
    return redirect('login')


@csrf_exempt
def api_login(request):
    if request.method == 'POST':
        data = _parse_json_body(request)
        if data is None:
            return JsonResponse({
                'success': False,
                'message': 'JSON inválido'
            }, status=400)

        username = data.get('username')
        password = data.get('password')
        
        user = authenticate(username=username, password=password)
        
        if user:
            auth_login(request, user)
            return JsonResponse({
                'success': True,
                'message': 'Inicio de sesión exitoso',
                'token': _create_api_token(user),
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
def api_logout(request):
    if request.method == 'POST':
        auth_logout(request)
        return JsonResponse({'success': True, 'message': 'Cierre de sesión exitoso'})
    return JsonResponse({'success': False, 'message': 'Método no permitido'}, status=405)


@csrf_exempt
def api_anuncios(request):
    user = _get_api_user(request)
    if not user:
        return JsonResponse({'success': False, 'message': 'No autorizado'}, status=401)

    if request.method == 'GET':
        anuncios = Anuncio.objects.filter(activo=True).order_by('-fecha_publicacion')[:20]
        return JsonResponse({
            'success': True,
            'anuncios': [
                {
                    'id': anuncio.id,
                    'titulo': anuncio.titulo,
                    'mensaje': anuncio.mensaje,
                    'prioridad': anuncio.prioridad,
                    'fecha_publicacion': anuncio.fecha_publicacion.isoformat(),
                    'publicado_por': anuncio.publicado_por.username if anuncio.publicado_por else None,
                }
                for anuncio in anuncios
            ]
        })

    elif request.method == 'POST' and user.is_superuser:
        data = _parse_json_body(request)
        if data is None:
            return JsonResponse({'success': False, 'message': 'JSON inválido'}, status=400)

        titulo = (data.get('titulo') or '').strip()
        mensaje = (data.get('mensaje') or '').strip()
        if not titulo or not mensaje:
            return JsonResponse({'success': False, 'message': 'Título y mensaje requeridos'}, status=400)

        anuncio = Anuncio.objects.create(
            titulo=titulo,
            mensaje=mensaje,
            prioridad=data.get('prioridad', 'normal'),
            activo=data.get('activo', True),
            publicado_por=user,
        )
        return JsonResponse({
            'success': True,
            'message': 'Anuncio creado correctamente',
            'anuncio': {
                'id': anuncio.id,
                'titulo': anuncio.titulo,
                'mensaje': anuncio.mensaje,
                'prioridad': anuncio.prioridad,
                'fecha_publicacion': anuncio.fecha_publicacion.isoformat(),
                'publicado_por': anuncio.publicado_por.username if anuncio.publicado_por else None,
            }
        }, status=201)

    return JsonResponse({'success': False, 'message': 'Método no permitido'}, status=405)


@csrf_exempt
def api_audiencias(request, pk=None):
    user = _get_api_user(request)

    if not user:
        return JsonResponse({'success': False, 'message': 'No autorizado'}, status=401)

    if request.method == 'GET':
        if pk:
            audiencia = get_object_or_404(Audiencia, pk=pk, usuario=user)
            data = _serialize_audiencia(audiencia, include_historial=True)
            return JsonResponse({'success': True, 'audiencia': data})
        else:
            audiencias = Audiencia.objects.filter(usuario=user).order_by('-fecha_hora')
            data = [_serialize_audiencia(a) for a in audiencias]
            return JsonResponse({'success': True, 'audiencias': data})
    
    elif request.method == 'POST':
        data = _parse_json_body(request)
        if data is None:
            return JsonResponse({
                'success': False,
                'message': 'JSON inválido'
            }, status=400)

        form = AudienciaForm(data)
        if form.is_valid():
            audiencia = form.save(commit=False)
            audiencia.usuario = user
            audiencia.add_to_historial(f'Audiencia registrada con estado {audiencia.estado}')
            audiencia.save()
            return JsonResponse({
                'success': True,
                'message': 'Audiencia creada correctamente',
                'audiencia': _serialize_audiencia(audiencia, include_historial=True)
            }, status=201)
        return JsonResponse({
            'success': False,
            'message': 'Error al crear la audiencia',
            'errors': form.errors
        }, status=400)
    
    elif request.method == 'PUT' and pk:
        audiencia = get_object_or_404(Audiencia, pk=pk, usuario=user)
        data = _parse_json_body(request)
        if data is None:
            return JsonResponse({
                'success': False,
                'message': 'JSON inválido'
            }, status=400)

        form = AudienciaForm(data, instance=audiencia)
        if form.is_valid():
            audiencia = form.save(commit=False)
            audiencia.add_to_historial('Se actualizó la información de la audiencia')
            audiencia.save()
            return JsonResponse({
                'success': True,
                'message': 'Audiencia actualizada correctamente',
                'audiencia': _serialize_audiencia(audiencia, include_historial=True)
            })
        return JsonResponse({
            'success': False,
            'message': 'Error al actualizar la audiencia',
            'errors': form.errors
        }, status=400)
    
    elif request.method == 'DELETE' and pk:
        audiencia = get_object_or_404(Audiencia, pk=pk, usuario=user)
        audiencia.delete()
        return JsonResponse({
            'success': True,
            'message': 'Audiencia eliminada correctamente'
        })
    
    return JsonResponse({'success': False, 'message': 'Método no permitido'}, status=405)
