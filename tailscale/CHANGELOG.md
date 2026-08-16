# Changelog

## 0.29.1

- Stop permanent Serve and Funnel validation failures from producing an S6
  restart storm.
- Report the actual Home Assistant HTTP status and provide actionable guidance
  when Home Assistant rejects the reverse-proxy test.
- Document the Home Assistant 2026.8 pending HTTP configuration confirmation,
  including its five-minute deadline.
- Add regression coverage for HTTP, HTTPS, unavailable, and rejected Home
  Assistant backends.

## 0.29.0

- Publish the first installable release of liliainbloom's Fork.
- Update Tailscale to `1.102.2`.
- Include the compatible upstream `main` changes and reviewed pull-request
  integrations documented in the
  [fork notes](https://github.com/liliainbloom/homeassistant-app-tailscale/blob/main/FORK_NOTES.md).
