# cron: health check with SMS alert

[`check-site.sh`](check-site.sh) checks a URL and sends an SMS when it is down. Run it from cron every five minutes:

```cron
CURLSMS_API_KEY=cs_test_…
*/5 * * * * /usr/local/bin/check-site.sh https://example.com/health +4915123456789
```

The `Idempotency-Key` in the script changes once per hour. While the site stays down you get **one SMS per hour**, not one every five minutes, without keeping any state on disk.

## Backup finished / failed

The same pattern works for any job:

```cron
0 3 * * * /usr/local/bin/backup.sh || /usr/local/bin/send-sms +4915123456789 "Backup on $(hostname) failed"
```

[`send-sms`](../../examples/bash/send-sms) is the small command-line tool from the examples.

## systemd instead of cron

```ini
# /etc/systemd/system/notify-sms@.service
[Unit]
Description=SMS when %i fails

[Service]
Type=oneshot
EnvironmentFile=/etc/curl-sms.env
ExecStart=/usr/local/bin/send-sms +4915123456789 "%i failed on %H"
```

Add `OnFailure=notify-sms@%n.service` to any unit you care about. `/etc/curl-sms.env` contains `CURLSMS_API_KEY=…` and should be readable by root only.
