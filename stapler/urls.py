# encoding: utf-8

from django.conf.urls.defaults import patterns
from django.views.generic.simple import direct_to_template
from stapler.decorators import login_required

from stapler.models import Staplerjob

urlpatterns = patterns('stapler.views',
    (r'home/$', 'home'),
    (r'holen/$',  'holen'),
    (r'zurueckmelden/$', 'zurueckmelden'),
)

urlpatterns += patterns('',
    (r'^$', 'django.views.generic.simple.direct_to_template', {'template': 'stapler/stapler.html'}),
    (r'job/(?P<object_id>\d+)/$', 'django.views.generic.list_detail.object_detail', 
                                {'queryset': Staplerjob.objects.all()}),
    (r'job/$', 'django.views.generic.list_detail.object_list', {'queryset': Staplerjob.objects.all()}),
)

