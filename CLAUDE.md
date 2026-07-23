# Repository Guidelines

`operto` is a host-agnostic Ruby client for the Operto Teams API, extracted from
the Guestit core app. It has no Rails dependency; the host injects credentials
and a token store via `Operto.configure`.

## Project Structure

- `lib/operto.rb` — entry point: requires, and the `Operto.configure`/`Operto.config` accessors.
- `lib/operto/client.rb` — the single HTTP gateway (Faraday connection, auth header, retry, response envelope).
- `lib/operto/config.rb` — injected `client_id`, `secret`, `token_store`, `base_url`.
- `lib/operto/operation.rb` — the monadic base (`#call` returns a Result, `#call!` unwraps/raises).
- `lib/operto/<resource>/<action>.rb` — one operation per file, namespaced `Operto::<Resource>::<Action>`.
- `spec/` — RSpec + VCR; cassettes in `spec/fixtures/cassettes`.

## Build, Test, and Development Commands

- Setup: `bundle install`.
- Test: `bundle exec rspec` (offline, VCR-backed) or `bundle exec rake` (spec + rubocop).
- Lint: `bundle exec rubocop` (or `-A` to autocorrect — review every change).

## Coding Style & Conventions

- Ruby: 2-space indent; `snake_case` methods/vars; `CamelCase` classes.
- Avoid multi-line method chains under 160 characters.
- Operations: `Operto::<Resource>::<Action>`, `include Operto::Operation`, `def call(...)`,
  return `Dry::Monads::Result`, invoke with a fresh instance (`Op.new.call(...)` / `Op.new.call!(...)`).
- Validate arguments up front with `argument!` / `required_attribute!` before any network call.
- Keep all HTTP and response normalization in `Operto::Client` and the operations; never leak
  Operto's wire keys (`PropertyID`, `TaskRuleID`, …) past the operation boundary.
- No `Rails`, `Time.zone` aside, or app constants — the gem stays framework-free (host injects config).

## Testing Guidelines

- Stack: RSpec + VCR + WebMock. Specs run offline against recorded cassettes.
- Configure `Operto` in a `before` hook with a fake token store (see `spec/support/test_token_store.rb`).
- Mirror the source tree: `spec/operto/<resource>/<action>_spec.rb`.

## Commit & Pull Request Guidelines

- Commits: short, imperative subject with a conventional prefix: `feat:`, `fix:`, `chore:`,
  `dev:`, `misc:`, `test:`, `docs:`. Use scoped subjects when useful (e.g., `feat(tasks): …`).
- PRs: clear description, linked issues, and a brief test plan. Ensure `bundle exec rake` passes.
