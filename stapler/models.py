# encoding: utf-8
""""
models.py

Created by Christian Klein on 2010-03-26.
Copyright (c) 2010 HUDORA GmbH. All rights reserved.
"""

import datetime
from django.db import models
from django.contrib.auth.models import User
try:
    import json
except:
    import simplejson as json

#from myplfrontend.tools import format_locname

def format_locname(locname):
    """Formats a location name nicely.

    >>> format_locname("010203")
    '01-02-03'
    >>> format_locname("AUSLAG")
    'AUSLAG'
    >>> format_locname("K20")
    'K20'
    """

    if len(locname) == 6 and str(locname).isdigit():
        return "%s-%s-%s" % (locname[:2], locname[2:4], locname[4:])
    return locname




STAPLERJOB_STATUS = (
    ('open', 'offen'),
    ('closed', 'abgeschlossen'),
    ('canceled', 'storniert'),
)


def make_job(user, movement):
    """
    Erzeuge Staplerjob für Movement aus dem myPL kernelE.
    
    So sehen die Daten aus:
    {'artnr': '10225',
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
    """

    if not movement:
        return None
    for key in ['from_location', 'to_location']:
        movement[key] = format_locname(movement[key])
    job = Staplerjob.objects.create(user=user, movement_id=movement['oid'],
                                    serialized_movement=json.dumps(movement, indent=2),
                                    status="open",
                                    created_at=datetime.datetime.now())
    return job


class Staplerjob(models.Model):
    """Represents a stored Movement for Stapler."""
    
    movement_id = models.CharField(max_length=32)
    status = models.CharField(max_length=16, choices=STAPLERJOB_STATUS, default="open")
    user = models.ForeignKey(User)
    serialized_movement = models.TextField()
    closed_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField() #auto_now_add=True) - Häh?
    
    def __unicode__(self):
        return u'ID: %s, User: %s, Movement ID: %s' % (self.id, self.user, self.movement_id)
    
    def deserialized(self):
        if not hasattr(self, '_deserialized'):
            self._deserialized = json.loads(self.serialized_movement)
        return self._deserialized
    
    def __unicode__(self):
        try:
            return "%(oid)s: %(artnr)s von %(from_location)s nach %(to_location)s" % self.deserialized()
        except KeyError:
            return unicode(self.movement_id)
    
    class Meta:
        verbose_name = "Staplerjob"
        verbose_name_plural = "Staplerjobs"
