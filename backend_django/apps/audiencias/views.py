from django.shortcuts import render, get_object_or_404, redirect
from django.contrib import messages
from django.utils import timezone
from django.db.models import Count, Q
from .models import Audiencia
from .forms import AudienciaForm


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


def audiencia_detail(request, pk):
    audiencia = get_object_or_404(Audiencia, pk=pk)
    context = {'audiencia': audiencia}
    return render(request, 'audiencias/detail.html', context)


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


def audiencia_delete(request, pk):
    audiencia = get_object_or_404(Audiencia, pk=pk)

    if request.method == 'POST':
        audiencia.delete()
        messages.success(request, 'Audiencia eliminada correctamente')
        return redirect('audiencia_list')

    context = {'audiencia': audiencia}
    return render(request, 'audiencias/delete_confirm.html', context)


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
