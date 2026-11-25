# GitHub Actions: SMS when a workflow fails

Two ways, both need a repository secret `CURLSMS_API_KEY` (**Settings → Secrets and variables → Actions**). Start with a test key (`cs_test_…`); nothing is sent or charged.

## With the action (recommended)

[`curl-sms/send-sms`](https://github.com/curl-sms/send-sms) handles escaping, retries and outputs the SMS id:

```yaml
- name: SMS on failure
  if: failure()
  uses: curl-sms/send-sms@v1
  with:
    api-key: ${{ secrets.CURLSMS_API_KEY }}
    receiver: "+4915123456789"
    body: "❌ ${{ github.repository }}: ${{ github.workflow }} failed on ${{ github.ref_name }}"
```

Full workflow: [`notify-on-failure.yml`](notify-on-failure.yml)

## With plain curl

```yaml
- name: SMS on failure
  if: failure()
  env:
    CURLSMS_API_KEY: ${{ secrets.CURLSMS_API_KEY }}
    TEXT: "${{ github.repository }}: ${{ github.workflow }} failed"
  run: |
    jq -n --arg b "$TEXT" '{receiver: "+4915123456789", body: $b}' |
    curl -fsS -X POST https://curl-sms.com/api/sms/send \
      -H "Authorization: Bearer $CURLSMS_API_KEY" \
      -H "Content-Type: application/json" \
      --data-binary @-
```

Pass values that come from the event (branch names, commit messages) through `env` and build the JSON with `jq`, never by pasting `${{ … }}` into the shell command: that keeps the step safe from script injection.
