# n8n: send SMS from any workflow

Use n8n's built-in **HTTP Request** node. No community node needed.

## Import the example

1. In n8n create a credential of type **Header Auth**:
   - **Name:** `Authorization`
   - **Value:** `Bearer cs_test_…`
   - Save it as `curl-sms`.
2. Open a workflow, choose **⋯ → Import from File** and select [`send-sms.workflow.json`](send-sms.workflow.json).
3. Open the **Send SMS** node and select the `curl-sms` credential.
4. Click **Test workflow**. With a test key the request is fully checked but nothing is sent or charged.

## Build it yourself

HTTP Request node settings:

| Field | Value |
|---|---|
| Method | `POST` |
| URL | `https://curl-sms.com/api/sms/send` |
| Authentication | Generic Credential Type → Header Auth → `curl-sms` |
| Send Body | on, **JSON**, *Using JSON* |
| JSON | `{{ JSON.stringify({ receiver: '+4915123456789', body: $json.message }) }}` |

`JSON.stringify` escapes quotes and line breaks in the message for you.

## Tips

- Add an `Idempotency-Key` header (e.g. `{{ $execution.id }}`) so a retried execution never sends twice.
- The response contains the SMS `id`. Store it, or receive delivery reports with an n8n **Webhook** trigger: see [webhooks](https://curl-sms.com/docs/webhooks).
