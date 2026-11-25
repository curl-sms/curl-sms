<?php

/**
 * Send an SMS with PHP's cURL extension (PHP 7.4+, no Composer packages).
 *
 * Usage:
 *   export CURLSMS_API_KEY=cs_test_…
 *   php send_sms.php "+4915123456789" "Hello from PHP"
 */

declare(strict_types=1);

function send_sms(string $receiver, string $body, ?string $idempotencyKey = null): array
{
    $key = getenv('CURLSMS_API_KEY');
    if ($key === false || $key === '') {
        throw new RuntimeException('Set CURLSMS_API_KEY to a key from https://curl-sms.com/app/keys');
    }

    $ch = curl_init('https://curl-sms.com/api/sms/send');
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 15,
        CURLOPT_HTTPHEADER => [
            'Authorization: Bearer ' . $key,
            'Content-Type: application/json',
            'Accept-Language: en',
            // Same key + same body within 24 h never sends twice: safe to retry.
            'Idempotency-Key: ' . ($idempotencyKey ?? bin2hex(random_bytes(16))),
        ],
        CURLOPT_POSTFIELDS => json_encode(['receiver' => $receiver, 'body' => $body], JSON_THROW_ON_ERROR),
    ]);

    $response = curl_exec($ch);
    if ($response === false) {
        throw new RuntimeException('Network error: ' . curl_error($ch));
    }
    $status = curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
    $data = json_decode((string) $response, true, 512, JSON_THROW_ON_ERROR);

    if ($status !== 202) {
        throw new RuntimeException(sprintf('%d %s: %s', $status, $data['error']['code'], $data['error']['message']));
    }
    return $data;
}

$sms = send_sms($argv[1] ?? '+4915123456789', $argv[2] ?? 'Hello from PHP');
printf("%s %s %d part(s) EUR %s\n", $sms['id'], $sms['status'], $sms['segments'], $sms['price']);
