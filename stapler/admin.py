#!/usr/bin/env python
# encoding: utf-8
"""
admin.py

Created by Christian Klein on 2010-03-28.
Copyright (c) 2010 HUDORA GmbH. All rights reserved.
"""

from django.contrib import admin
from stapler.models import Staplerjob

class StaplerjobAdmin(admin.ModelAdmin):
    list_display = ('id', '__unicode__', 'status', 'created_at', 'closed_at', 'user')
    list_filter = ('status', 'created_at', 'closed_at', 'user')
    fieldsets = (
            (None, {
                'fields': ('status', 'closed_at')
            }),
            ('Do not change', {
                'fields': ('movement_id', 'serialized_movement', 'created_at')
            }),
        )

admin.site.register(Staplerjob, StaplerjobAdmin)
