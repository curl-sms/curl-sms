// Send an SMS with the Go standard library (no dependencies).
//
// Usage:
//
//	export CURLSMS_API_KEY=cs_test_…
//	go run . "+4915123456789" "Hello from Go"
package main

import (
	"bytes"
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"
)

// Message is the SMS as returned by the API.
type Message struct {
	ID        string  `json:"id"`
	Status    string  `json:"status"`
	Segments  int     `json:"segments"`
	Encoding  string  `json:"encoding"`
	Price     string  `json:"price"`
	ErrorCode *string `json:"error_code"`
}

// APIError is the error body: {"error":{"code":"…","message":"…"}}.
type APIError struct {
	Status int
	Code   string `json:"code"`
	Msg    string `json:"message"`
}

func (e *APIError) Error() string { return fmt.Sprintf("%d %s: %s", e.Status, e.Code, e.Msg) }

// SendSMS sends one SMS. The idempotency key makes retries safe.
func SendSMS(ctx context.Context, key, receiver, body, idempotencyKey string) (*Message, error) {
	payload, err := json.Marshal(map[string]string{"receiver": receiver, "body": body})
	if err != nil {
		return nil, err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, "https://curl-sms.com/api/sms/send", bytes.NewReader(payload))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Bearer "+key)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept-Language", "en")
	req.Header.Set("Idempotency-Key", idempotencyKey)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusAccepted {
		var e struct {
			Error APIError `json:"error"`
		}
		if err := json.NewDecoder(resp.Body).Decode(&e); err != nil {
			return nil, fmt.Errorf("unexpected status %d", resp.StatusCode)
		}
		e.Error.Status = resp.StatusCode
		return nil, &e.Error
	}
	var m Message
	return &m, json.NewDecoder(resp.Body).Decode(&m)
}

func newKey() string {
	b := make([]byte, 16)
	_, _ = rand.Read(b)
	return hex.EncodeToString(b)
}

func main() {
	key := os.Getenv("CURLSMS_API_KEY")
	if key == "" {
		fmt.Fprintln(os.Stderr, "Set CURLSMS_API_KEY to a key from https://curl-sms.com/app/keys")
		os.Exit(2)
	}
	receiver, text := "+4915123456789", "Hello from Go"
	if len(os.Args) > 2 {
		receiver, text = os.Args[1], os.Args[2]
	}

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	m, err := SendSMS(ctx, key, receiver, text, newKey())
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Println(m.ID, m.Status, m.Segments, "part(s)", "EUR", m.Price)
}
