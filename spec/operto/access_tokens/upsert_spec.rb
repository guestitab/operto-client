RSpec.describe Operto::AccessTokens::Upsert do
  subject(:result) { described_class.new.call }

  let(:store) { Operto.config.token_store }

  context 'when a valid token already exists' do
    it 'returns it without a request' do
      expect(result.value!.access_token).to eq('test-access-token')
    end
  end

  context 'when the token is expired but refreshable', vcr: { cassette_name: 'access_tokens/upsert/with_refresh_token' } do
    before do
      store.save(access_token: 'expired-token', expires_at: Time.now - 3600,
                 refresh_token: 'refresh-token', refresh_expires_at: Time.now + 3600)
    end

    it 'refreshes and stores a new access token' do
      expect(result.value!.access_token).to be_a(String)
      expect(store.active.access_token).not_to eq('expired-token')
    end
  end

  context 'when the token is expired and not refreshable', vcr: { cassette_name: 'access_tokens/upsert' } do
    before do
      store.save(access_token: 'expired-token', expires_at: Time.now - 3600,
                 refresh_token: 'expired-refresh', refresh_expires_at: Time.now - 3600)
    end

    it 'logs in and stores a new access token' do
      expect(result.value!.access_token).to be_a(String)
    end
  end

  context 'when no token exists', vcr: { cassette_name: 'access_tokens/upsert' } do
    before { store.clear }

    it 'logs in and stores a token' do
      expect(result.value!.access_token).to be_a(String)
      expect(store.active).not_to be_nil
    end
  end
end
