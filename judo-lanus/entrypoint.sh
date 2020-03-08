#!/bin/bash

# Migrations will be here
# This is for the Django DRF files
python manage.py collectstatic --noinput
uwsgi --emperor /services/vassal --uid vero-api