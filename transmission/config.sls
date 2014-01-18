{% from "transmission/map.jinja" import transmission, transmission_daemon with context %}

include:
  - transmission

transmission_daemon_settings_file:
  file.serialize:
    - name: {{ transmission_daemon.settings_file }}
    - user: {{ transmission.user }}
    - group: {{ transmission.group }}
    - mode: 600
    - require:
      - pkg: transmission_daemon
    - formatter: json
    - dataset:
        {%- for key, value in pillar.get('transmission_daemon_settings', {}).iteritems() %}
            {%- if value is sameas true %}
        {{ key }}: True
            {%- elif value is sameas false %}
        {{ key }}: False
            {%- elif value is number %}
        {{ key }}: {{ value }}
            {%- else %}
        {{ key }}: "{{ value }}"
            {%- endif %}
        {%- endfor %}

transmission_daemon_sighup:
  cmd.wait:
    - name: pkill -HUP transmission-da
    - watch:
      - file: transmission_daemon_settings_file
