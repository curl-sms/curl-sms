# Home Assistant: SMS notifications

Send SMS from Home Assistant automations with a `rest_command`. Useful for alerts that must reach you even when push notifications don't: water leak, smoke, power failure.

## 1. Add the command

Copy [`configuration.yaml`](configuration.yaml) into your `configuration.yaml` and add the key to `secrets.yaml`:

```yaml
curlsms_auth: "Bearer cs_test_…"
```

Restart Home Assistant. With a test key every request is checked but nothing is sent or charged; switch to `cs_live_…` when it works.

## 2. Use it in an automation

```yaml
action: rest_command.send_sms
data:
  receiver: "+4915123456789"
  message: "Water leak detected in the basement"
```

A complete automation is in [`automation.yaml`](automation.yaml).

## Tips

- The payload is built with `to_json`, so quotes and line breaks in your message never break the JSON.
- Keep alert texts short: one SMS part holds 160 characters (70 with emoji).
- Add a condition or cooldown so a flapping sensor doesn't send dozens of SMS.
- Got a Synology NAS? The [curl-sms app for Synology](https://curl-sms.com/synology-nas-sms) also accepts messages via MQTT and queues them locally when the internet is down.

More: [Home Assistant SMS guide](https://curl-sms.com/home-assistant-sms)
