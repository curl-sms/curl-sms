<h1 align="center">curl-sms</h1>

<p align="center">
  <strong>SMS API for developers. Send a text message with one HTTP call.</strong><br>
  Examples for curl, Python, Node.js, Go, PHP, Bash and PowerShell, plus recipes for Home Assistant, Uptime Kuma, n8n, cron and GitHub Actions.
</p>

<p align="center">
  <a href="https://github.com/curl-sms/curl-sms/actions/workflows/ci.yml"><img alt="CI" src="https://github.com/curl-sms/curl-sms/actions/workflows/ci.yml/badge.svg"></a>
  <a href="https://curl-sms.com/docs/api"><img alt="OpenAPI 3.1" src="https://img.shields.io/badge/OpenAPI-3.1-0a0a0a"></a>
  <a href="LICENSE"><img alt="MIT license" src="https://img.shields.io/badge/license-MIT-0a0a0a"></a>
</p>

<p align="center">
  <a href="https://curl-sms.com">Website</a> ·
  <a href="https://curl-sms.com/docs">Docs</a> ·
  <a href="https://curl-sms.com/docs/api">API reference</a> ·
  <a href="https://curl-sms.com/pricing">Pricing</a> ·
  <a href="https://curl-sms.com/integrations">Integrations</a>
</p>

---

## Quickstart (30 seconds)

1. [Sign in](https://curl-sms.com/login) and create a **test key** under [API keys](https://curl-sms.com/app/keys). Test keys (`cs_test_…`) run every check, send nothing and cost nothing.
2. Send your first SMS:

```sh
export CURLSMS_API_KEY=cs_test_…

curl -X POST https://curl-sms.com/api/sms/send \
  -H "Authorization: Bearer $CURLSMS_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"receiver":"+4915123456789","body":"Hello from curl-sms"}'
```

3. The API answers `202 Accepted`:

```json
{
  "id": "01JDQ8M3V6R1T5ZK2X9N4C7B0A",
  "mode": "test",
  "receiver": "+4915123456789",
  "status": "queued",
  "segments": 1,
  "encoding": "gsm7",
  "price": "0.00",
  "error_code": null,
  "created_at": "2026-11-25T10:15:00.000Z",
  "send_at": null,
  "sent_at": null,
  "delivered_at": null,
  "refunded": false
}
```

Switch to a live key (`cs_live_…`) when everything works. Your code stays the same. The Free plan includes 5 SMS per month, no payment details needed.

## Examples

| Language | File | Notes |
|---|---|---|
| curl | [`examples/curl/`](examples/curl) | send, bulk + scheduled, status, estimate, account |
| Python | [`examples/python/send_sms.py`](examples/python/send_sms.py) | standard library only; [`wait_for_delivery.py`](examples/python/wait_for_delivery.py) polls the status |
| Node.js | [`examples/node/send-sms.mjs`](examples/node/send-sms.mjs) | built-in `fetch`, Node 18+ |
| Go | [`examples/go/main.go`](examples/go/main.go) | standard library only |
| PHP | [`examples/php/send_sms.php`](examples/php/send_sms.php) | cURL extension, PHP 7.4+ |
| Bash | [`examples/bash/send-sms`](examples/bash/send-sms) | tiny CLI: `send-sms +49… "text"` or pipe text in |
| PowerShell | [`examples/powershell/Send-Sms.ps1`](examples/powershell/Send-Sms.ps1) | Windows PowerShell 5.1 and PowerShell 7 |
| Webhooks | [`examples/webhooks/`](examples/webhooks) | verify signed delivery reports in Flask and Express |

Every example reads the key from `CURLSMS_API_KEY` and uses the example number `+4915123456789`.

### Client libraries

| | Install | Repository |
|---|---|---|
| Python | `pip install curl-sms` | [curl-sms/curl-sms-python](https://github.com/curl-sms/curl-sms-python) |
| Node.js / TypeScript | `npm install curl-sms` | [curl-sms/curl-sms-node](https://github.com/curl-sms/curl-sms-node) |
| GitHub Actions | `uses: curl-sms/send-sms@v1` | [curl-sms/send-sms](https://github.com/curl-sms/send-sms) |
| AI assistants (MCP) | `https://curl-sms.com/mcp` | [curl-sms/curl-sms-mcp](https://github.com/curl-sms/curl-sms-mcp) |

Docs: [Python](https://curl-sms.com/docs/python) · [Node.js](https://curl-sms.com/docs/node) · [GitHub Action](https://curl-sms.com/docs/github-action) · [MCP](https://curl-sms.com/docs/mcp). Also available as a [Synology app](https://curl-sms.com/docs/nas-app) and a [self-hosted bridge for Docker](https://curl-sms.com/docs/bridge); see [all integrations](https://curl-sms.com/integrations).

Any other language works too: generate a client from [`openapi.yaml`](openapi.yaml) or call the API with your HTTP library.

## Recipes

| Use case | Recipe |
|---|---|
| Smart home alerts (water leak, smoke, alarm) | [Home Assistant](recipes/home-assistant) |
| Website or server down | [Uptime Kuma](recipes/uptime-kuma) |
| Workflow automation | [n8n](recipes/n8n) |
| Health checks, backups, failed systemd units | [cron / systemd](recipes/cron) |
| Failed deploys and CI runs | [GitHub Actions](recipes/github-actions) |

## The API at a glance

| Method | Endpoint | Purpose |
|---|---|---|
| `POST` | `/api/sms/send` | Send one SMS (`receiver`) or the same text to up to 100 receivers (`receivers`), now or at `send_at` |
| `POST` | `/api/sms/estimate` | Parts, encoding, price and whether sending is allowed, without sending |
| `GET` | `/api/sms/{id}` | Status of one SMS |
| `DELETE` | `/api/sms/{id}` | Cancel a scheduled SMS (refunded) or delete its text |
| `GET` | `/api/sms` | List SMS, or only changes since a cursor |
| `GET` | `/api/account` | Plan, included SMS, balance and limits |

- **Auth:** `Authorization: Bearer <key>`.
- **Safe retries:** send an `Idempotency-Key` header. The same key and body within 24 hours return the stored response and never send twice.
- **Status:** `queued` → `sent` → `delivered`; also `scheduled`, `failed` (refunded), `expired` and `canceled`. Rely on `sent`; `delivered` needs a delivery report from the network.
- **Delivery reports:** signed webhooks (`sms.status_changed`), see [webhooks](https://curl-sms.com/docs/webhooks).
- **Errors:** always `{"error":{"code":"…","message":"…"}}`, see [error codes](https://curl-sms.com/docs/error-codes).
- **Length:** 160 characters per part (GSM-7), 70 with emoji or other Unicode, up to 10 parts.
- **Rate limit:** 10 requests per second per key, then `429` with `Retry-After`.
- **No surprise bills:** prepaid only. When included SMS and balance are used up, the API answers `402`.

Full reference: [curl-sms.com/docs/api](https://curl-sms.com/docs/api) · machine-readable: [`openapi.yaml`](openapi.yaml)

## Guides

[Send SMS with Python](https://curl-sms.com/send-sms-python) ·
[Node.js](https://curl-sms.com/send-sms-nodejs) ·
[Go](https://curl-sms.com/send-sms-go) ·
[PHP](https://curl-sms.com/send-sms-php) ·
[Bash](https://curl-sms.com/send-sms-bash) ·
[PowerShell](https://curl-sms.com/send-sms-powershell) ·
[HTTP](https://curl-sms.com/send-sms-http) ·
[2FA codes](https://curl-sms.com/sms-2fa-verification-codes) ·
[Monitoring alerts](https://curl-sms.com/sms-alerts-server-monitoring) ·
[Email to SMS](https://curl-sms.com/email-to-sms) ·
[Synology NAS](https://curl-sms.com/synology-nas-sms) ·
[AI assistants](https://curl-sms.com/send-sms-ai-assistant)

## Contributing

Found a mistake or want another example? Issues and pull requests are welcome, see [CONTRIBUTING](https://github.com/curl-sms/.github/blob/main/CONTRIBUTING.md). Account or billing questions: [help@curl-sms.com](mailto:help@curl-sms.com).

## License

The examples, recipes and `openapi.yaml` in this repository are [MIT licensed](LICENSE). Use of the curl-sms service is subject to the [terms](https://curl-sms.com/terms).
