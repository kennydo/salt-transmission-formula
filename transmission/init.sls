{% from "transmission/map.jinja" import transmission, transmission_daemon with context %}

transmission_daemon:
  pkg.installed:
    - name: {{ transmission_daemon.package }}
  service.running:
    - enable: True
    - name: {{ transmission_daemon.service }}
    - require:
      - pkg: transmission_daemon
