# encoding: utf-8

from django.contrib import admin
from stapler.models import Staplerjob

def StaplerjobAdmin(admin.ModelAdmin):
    date_hierarchy = 'created_at'
    list_display = ('movement_id', 'from_location', 'to_location', 'status', 'user__username')
    list_filter = ('status', 'user')
    search_fields = ('movement_id', )

    movement_id = models.CharField(max_length=32)
    status = models.CharField(max_length=16, choices=STAPLERJOB_STATUS, default="open")
    user = models.ForeignKey(User)
    serialized_movement = models.TextField()
    closed_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField() #auto_now_add=True) - Häh?

admin.site.register(Staplerjob, StaplerjobAdmin)
