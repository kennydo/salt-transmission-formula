{% from "transmission/map.jinja" import transmission, transmission_daemon with context %}

include:
  - transmission

transmission_daemon_settings_file:
  file.managed:
    - name: {{ transmission_daemon.settings_file }}
    - user: {{ transmission.user }}
    - group: {{ transmission.group }}
    - mode: 600
    - require:
      - pkg: transmission_daemon
    - contents: |
        {
            {%- for key, value in pillar.get('transmission_daemon_settings', {})|dictsort %}
                {%- if value is sameas true %}
            "{{ key }}": true
                {%- elif value is sameas false %}
            "{{ key }}": false
                {%- elif value is number %}
            "{{ key }}": {{ value }}
                {%- else %}
            "{{ key }}": "{{ value }}"
                {%- endif -%}{% if not loop.last %}, {% else %}
        {% endif %}
            {%- endfor -%}
        }

transmission_daemon_sighup:
  cmd.wait:
    - name: pkill -HUP transmission-da
    - watch:
      - file: transmission_daemon_settings_file
    - watch_in:
      - service: transmission_daemon
