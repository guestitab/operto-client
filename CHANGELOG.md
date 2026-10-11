# Changelog

## 0.4.0 - 2026-10-12

- When Operto rejects the access token (a `401` or an `auth_token_expired` response), the client clears the token store, renews the token and replays the request once.
- A host token store's `clear` must retire the token so the next `active` returns `nil`.
- Retry only idempotent requests, and only on `502`, `503` and `504`. `POST` and `PATCH` requests and `429` responses are no longer retried.
- `Homes::Index` and `Staff::Index` keep an unparseable create date as the raw value instead of failing with `Date::Error`.

## 0.3.0 - 2026-09-27

- `Tasks::Index` returns the whole task: rule, booking, name, description, start and due times, and the active and completion flags.
- Add `Tasks::Show` for one task. A missing task fails with `Operto::NotFoundError`.
- `Tasks::Update` sends only the attributes it gets, so a description-only update keeps the name, schedule and rule.

## 0.2.0 - 2026-08-17

- Add RBS type signatures for the public API.
- Add RubyGems project, changelog, and license metadata.
- Package the README, changelog, and license with the gem.
- Bound runtime dependencies to the supported major versions.

## 0.1.0 - 2026-07-23

- Initial release of the Operto Teams API client, including the default in-memory token store.
