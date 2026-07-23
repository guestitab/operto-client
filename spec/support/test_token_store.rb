# In-memory token store for the specs, standing in for the host's persistence.
class TestTokenStore
  Token = Struct.new(:access_token, :refresh_token, :refresh_expires_at, :expires_at, keyword_init: true) do
    def expired?
      expires_at.nil? || expires_at < Time.now
    end
  end

  def self.with_active_token
    new(token: Token.new(access_token: 'test-access-token', expires_at: Time.now + 3600))
  end

  attr_accessor :token

  def initialize(token: nil)
    @token = token
  end

  def active
    token if token && !token.expired?
  end

  def refreshable
    token if token&.refresh_expires_at && token.refresh_expires_at > Time.now + 120
  end

  def save(access_token:, expires_at:, refresh_token: nil, refresh_expires_at: nil)
    @token = Token.new(access_token:, expires_at:, refresh_token:, refresh_expires_at:)
  end

  def clear
    @token = nil
  end
end
