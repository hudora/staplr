# encoding: utf-8
""""
views.py

Created by Christian Klein on 2010-03-26.
Copyright (c) 2010 HUDORA GmbH. All rights reserved.
"""

import datetime
from django.http import HttpResponse, Http404
from django.shortcuts import get_object_or_404
from django.views.decorators.http import require_POST

from stapler.models import Staplerjob, make_job
from stapler.decorators import login_required
from hudjango.decorators import ajax_request
#from myplfrontend.kernelapi import Kerneladapter
from cs.zwitscher import zwitscher
import pprint


@login_required
@ajax_request
def home(request):
    """View zur Feststellung, ob User eingeloggt ist."""
    return {'status': 'OK', 'username': request.user.username}


@login_required
@require_POST
def holen(request):
    """Staplerjob anfordern"""
    try:
        job = Staplerjob.objects.get(status='open', user=request.user)
    except Staplerjob.DoesNotExist:
        
        movement = {'artnr': '10225',
         'attr': 'test',
         'created_at': '2010-03-29T09:39:00.855806Z',
         'from_location': '110303',
         'menge': 11,
         'mui': '340059981002670930',
         'mypl_notify_requesttracker': True,
         'oid': 'mb09191995',
         'reason': 'requesttracker',
         'status': 'open',
         'to_location': '032201'}
        
        # movement = Kerneladapter().get_next_movement(attr='%s via myPL Stapler' % request.user.username)
        
        pprint.pprint(movement)
        if not movement:
            raise Http404("No movement available.")
        #zwitscher("Movement %s via Stapler Terminal erzeugt" % movement['oid'], username="stapler")
        job = make_job(request.user, movement)
    return HttpResponse(job.serialized_movement, mimetype='text/plain')


@login_required
@require_POST
@ajax_request
def zurueckmelden(request):
    """
    Staplerjob zurückmelden
    
    Wenn der Auftrag nicht erfolgreich ausgeführt werden konnte,
    ist das Feld 'storno' im POST-Dictionary gesetzt.
    """

    movement_id = request.POST.get('movement_id', '')
    print "movement_id:", movement_id
    print "100000000000"
    job = get_object_or_404(Staplerjob, movement_id=movement_id, user=request.user, status='open')
    print "200000000000"
    if 'storno' in request.POST:
        print "STORNO!"
        # zwitscher("Staplerauftrag %s wurde storniert", username="stapler")
        # automatisches Storno?
        # Kerneladapter().movement_stornieren(movement_id, request.user.name, "Storno von Stapler")
        job.status = 'canceled'
    else:
        print "COMMIT!"
        # Kerneladapter().commit_movement(movement_id)
        job.status = 'closed'
    print "300000000000"
    job.closed_at = datetime.datetime.now()
    print "400000000000"
    job.save()
    print "500000000000"
    return {'status': 'OK'}
