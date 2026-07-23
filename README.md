# Operto

A Ruby client for the [Operto Teams](https://teams.operto.com) API. Every call
is an operation returning a [`Dry::Monads::Result`](https://dry-rb.org/gems/dry-monads/);
credentials and token storage are injected by the host, so the gem carries no
framework dependency.

## Installation

```ruby
# Gemfile
gem 'operto', github: 'guestitab/oporto-client'
```

```sh
bundle install
```

## Configuration

Configure once at boot with your API credentials and a token store. In Rails,
put this in `config/initializers/operto.rb`:

```ruby
Rails.application.config.to_prepare do
  Operto.configure do |config|
    config.client_id    = Rails.application.credentials.dig(:operto, :client_id)
    config.secret       = Rails.application.credentials.dig(:operto, :secret)
    config.token_store  = MyTokenStore.new
  end
end
```

### Token store

The gem performs the OAuth login/refresh but delegates persistence and caching
to your store. Implement these four methods:

| Method | Returns / does |
| --- | --- |
| `active` | the current non-expired token, or `nil` |
| `refreshable` | a token whose refresh token is still valid, or `nil` |
| `save(access_token:, expires_at:, refresh_token: nil, refresh_expires_at: nil)` | persist and return the token |
| `clear` | drop the cached token (called after a `401`) |

A token responds to `access_token`, `refresh_token`, `refresh_expires_at`, and
`expired?`.

## Usage

```ruby
Operto::Tasks::Create.new.call(
  attributes: {
    house_id:   '110784',
    rule_id:    '27986',
    name:       'Deep clean',
    start_date: Time.zone.parse('2026-01-01 09:00'),
    end_date:   Time.zone.parse('2026-01-02 09:00')
  }
)
# => Success({ task_id: 44683131 })
```

`#call` returns a `Result`; `#call!` unwraps it and raises the underlying
failure. Operations are grouped by resource:

- `Operto::Tasks::{Create,Update,Index}`
- `Operto::StaffTasks::{Create,Destroy}` · `Operto::StaffTaskTimes::Index`
- `Operto::Issues::{Index,Close}` · `Operto::Homes::Index` · `Operto::Staff::Index`

## Development

```sh
bundle install
bundle exec rake        # spec + rubocop
```

HTTP interactions are recorded with [VCR](https://github.com/vcr/vcr); specs run
offline against `spec/fixtures/cassettes`.

## License

Released under the [MIT License](LICENSE).
