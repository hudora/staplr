
import random
try:
    import json
except:
    import simplejson as json
import time
import datetime

from django.http import HttpResponse, Http404, settings
from django.shortcuts import render_to_response, get_object_or_404
from django.template import RequestContext
from django.views.decorators.http import require_POST
from django.contrib.auth import authenticate, login, logout
#from myplfrontend.kernelapi import Kerneladapter
## XXX: REMOVE AS SOON AS POSSIBLE:
#from mypl.kernel import Kerneladapter as OldKerneladapter

from models import Staplerjob, make_job
from decorators import login_required
#from cs.zwitscher import zwitscher

_is_debug = getattr(settings, 'DEBUG')


def index(request):
    return render_to_response('stapler/application.html',{}, context_instance=RequestContext(request))

def is_logged_in(request):
    is_logged_in = request.user.is_authenticated()
    job_count = Staplerjob.objects.filter(status='open', user=request.user).count()
    current_movement = job_count > 0
    return _render_to_json({'login':is_logged_in,
                            'current_movement': current_movement})

@require_POST
def do_login(request):
    username = request.POST.get('username')
    password = request.POST.get('password')
    user = authenticate(username=username, password=password)
    request.session['credentials'] = {'username': username, 'password': password} # Das bereitet mir wirklich Schmerzen!
    if user is not None:
        if user.is_active:
            login(request, user)
            return _render_to_json({'status':'OK'})
    return _render_to_json({'status':'FAIL'})

@require_POST
def do_logout(request):
    logout(request)
    return _render_to_json({'status':'OK'})

@login_required
def has_current_movement(request):
    try:
        return _render_to_json({'movement':True})
    except:
        return _render_to_json({'movement':False})

@require_POST
@login_required
def fetch_movement(request):
    # zuerst gucken wir, ob wir noch einen aktuellen Job in der DB haben
    try:
        job = Staplerjob.objects.get(status='open', user=request.user)
        json = job.serialized_movement

    # nein, haben wir nicht, also holen wir uns einen neuen Job vom Kernel
    # oder erzeugen im Debug-Mode ein Testmovement. Wenn wir einen Fehler 
    # vom Kernel bekommen zeigen wir auf dem iPhone ebenfalls einen Fehler an.
    except Staplerjob.DoesNotExist:
        if _is_debug:
            movement = _get_dummy_movement()
        else:
            try:
                #movement = Kerneladapter().get_next_movement(attr='%s via myPL Stapler' % request.user.username)
                movement = None
            except Exception:
                return HttpRespone('{"status":"exception"}', mimetype='application/json')

        # haben wir ein Movement vom Kernel bekommen? Wenn ja legen wir es
        # als Job in der lokalen DB ab und erzeugen die Ausgabe fuer den Client,
        # ansonsten gibt's eine passende Fehlermeldung fuer den Kernel
        if movement:
            job = make_job(request.user, movement)
            json = job.serialized_movement
        else:
            json = '{"status":"not_found"}'

    # und jetzt noch die fertige Msg zum Client liefern, fettich.
    return HttpResponse(json, mimetype='application/json')

@require_POST
@login_required
def commit_or_cancel_movement(request, what, oid):
    job = get_object_or_404(Staplerjob, movement_id=oid, user=request.user, status='open')
    if what == 'storno':
        # Kerneladapter().movement_stornieren(oid, request.user.name, 'Storno via myPL Stapler')
        #zwitscher("Staplerauftrag %s wurde storniert" % oid, username="stapler")
        job.status = 'canceled'
    else:
        # Der neue (HTTP-basierte) Kerneladapter unterstuetzt noch kein Rueckmelden von Movements:
        #Kerneladapter().commit_movement(oid)
        #OldKerneladapter().commit_movement(oid)
        job.status = 'closed'
    job.closed_at = datetime.datetime.now()
    job.save()
    return _render_to_json({ 'status': 'OK' })

def _render_to_json(data):
    json_data = json.dumps(data)
    return HttpResponse(json_data, mimetype='application/json')

def _get_dummy_movement():
    ident = str(random.randint(10, 90))
    return { 'artnr': '1025' + ident,
             'attr': 'test',
             'created_at': '2010-03-29T09:39:00.855806Z',
             'from_location': '1103' + ident,
             'to_location': '03' + ident + '01',
             'menge': 11,
             'mui': '340059981002670930',
             'mypl_notify_requesttracker': True,
             'oid': 'mb091919' + ident,
             'reason': 'requesttracker',
             'status': 'open' }
