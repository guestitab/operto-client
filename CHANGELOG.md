# Changelog

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
