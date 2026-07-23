module Operto
  # Injected by the host app (see the Operto.configure initializer): the API
  # credentials, a cache, and a token store. Keeping these out of the gem is
  # what makes it host-agnostic.
  class Config
    attr_accessor :client_id, :secret, :token_store, :base_url

    def initialize
      @base_url = 'https://teams-api.operto.com/api/v1/'.freeze
      @token_store = MemoryTokenStore.new
    end
  end
end
