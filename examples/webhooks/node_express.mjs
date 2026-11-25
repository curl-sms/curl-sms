// Receive and verify curl-sms webhooks with Express.
//
// Usage:
//   npm install express
//   export CURLSMS_WEBHOOK_SECRET=whsec_…
//   node node_express.mjs
//
// Add https://<your-host>/hooks/curl-sms under https://curl-sms.com/app/webhooks.
// Docs: https://curl-sms.com/docs/webhooks
import crypto from 'node:crypto';
import express from 'express';

const SECRET = process.env.CURLSMS_WEBHOOK_SECRET ?? '';
const seen = new Set(); // use your database in production

export function verify(secret, header, rawBody, toleranceSec = 300) {
  const parts = Object.fromEntries(header.split(',').map((p) => p.split('=')));
  const t = Number(parts.t);
  if (!parts.v1 || !Number.isInteger(t) || Math.abs(Date.now() / 1000 - t) > toleranceSec) return false;
  const mac = crypto.createHmac('sha256', secret).update(`${parts.t}.`).update(rawBody).digest();
  const sig = Buffer.from(parts.v1, 'hex');
  return sig.length === mac.length && crypto.timingSafeEqual(mac, sig);
}

const app = express();

// express.raw keeps the exact bytes the signature was computed over.
app.post('/hooks/curl-sms', express.raw({ type: 'application/json' }), (req, res) => {
  if (!verify(SECRET, req.get('X-CurlSMS-Signature') ?? '', req.body)) return res.sendStatus(400);

  const event = JSON.parse(req.body.toString('utf8'));
  if (seen.has(event.id)) return res.sendStatus(204); // delivery is at-least-once
  seen.add(event.id);

  if (event.type === 'sms.status_changed') {
    console.log(`SMS ${event.data.id} is now ${event.data.status}`, event.data.error_code ?? '');
  }
  res.sendStatus(204);
});

app.listen(8000, () => console.log('Listening on http://localhost:8000/hooks/curl-sms'));
