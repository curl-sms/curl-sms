# Uptime Kuma: SMS when a monitor goes down

Uptime Kuma's **Webhook** notification can call the curl-sms API directly. Tested with Uptime Kuma 1.23 and 2.x.

## Setup

1. In Uptime Kuma open **Settings → Notifications → Setup Notification**.
2. **Notification Type:** `Webhook`
3. **Post URL:** `https://curl-sms.com/api/sms/send`
4. **Request Body:** `Custom Body`, with:

   ```json
   {
     "receiver": "+4915123456789",
     "body": {{ msg | truncate: 300 | json }}
   }
   ```

   The `json` filter quotes and escapes the message, so special characters never break the request. `truncate` keeps the SMS at two parts at most.

5. Enable **Additional Headers** and enter:

   ```json
   {
     "Authorization": "Bearer cs_test_…",
     "Accept-Language": "en"
   }
   ```

6. Click **Test**. With a test key the request is fully checked but nothing is sent or charged. Replace it with a live key (`cs_live_…`) and save.
7. Enable the notification on the monitors that should alert by SMS.

## Tips

- Use **Apply on all existing monitors** only if you really want an SMS for every monitor.
- Uptime Kuma sends one notification for *down* and one for *up*. That is usually what you want; if not, use a separate status page or a cron check (see [`../cron`](../cron)).
- Set a spend limit and subscribe to the `billing.balance_low` webhook so your alerts never stop silently. Without balance the API answers `402`.

More: [SMS alerts for server monitoring](https://curl-sms.com/sms-alerts-server-monitoring)
