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
    # We manually make the template for the JSON instead of using the JSON
    # serializer because the transmission-daemon writes the JSON file
    # with a space after each comma (at the end of the line).
    # We mimic this so that the file diffs that salt gives the user
    # shows only the settings that changed (instead of the entire file).
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
    # The SIGHUP signal makes the daemon reload the settings file.
    - name: pkill -HUP transmission-da
    - watch:
      - file: transmission_daemon_settings_file
    - watch_in:
      # When the transmission-daemon service stops, it writes its current
      # settings into the settings.json. Therefore, we must first send the
      # SIGHUP signal to make the daemon reload the settings, then we
      # restart the service to make the daemon write the settings back to
      # the JSON file.
      # This is for handling sensitive info like the rpc-password, which
      # the daemon hashes before writing back into the JSON file.
      - service: transmission_daemon
