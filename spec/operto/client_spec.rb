RSpec.describe Operto::Client do
  describe '.connection' do
    subject(:response) { described_class.connection.get('tasks/1') }

    let(:url) { 'https://teams-api.operto.com/api/v1/tasks/1' }
    let(:json) { { 'Content-Type' => 'application/json' } }
    let(:expired) { { ReasonCode: 401, ReasonText: 'api.response.error.auth_token_expired' }.to_json }
    let(:found) { { status: 200, body: { data: [] }.to_json, headers: json } }

    before do
      stub_request(:post, 'https://teams-api.operto.com/api/v1/oauth/login').to_return(
        status: 201,
        body: { Access_Token: { token: 'renewed-token', Expiry: '3600' }, Refresh_Token: { token: 'refresh-token', Expiry: '86400' } }.to_json,
        headers: json
      )
    end

    context 'when Operto rejects the token' do
      before { stub_request(:get, url).to_return({ status: 401, body: expired, headers: json }, found) }

      it 'renews the token and replays the request once' do
        expect(response.status).to eq(200)
        expect(WebMock).to have_requested(:get, url).with(headers: { 'Authorization' => 'VRS test-access-token' }).once
        expect(WebMock).to have_requested(:get, url).with(headers: { 'Authorization' => 'VRS renewed-token' }).once
      end

      context 'with the renewed token rejected too' do
        before { stub_request(:get, url).to_return(status: 401, body: expired, headers: json) }

        it 'returns the rejection after one replay' do
          expect(response.status).to eq(401)
          expect(WebMock).to have_requested(:get, url).twice
        end
      end

      context 'with a POST' do
        subject(:response) { described_class.connection.post('tasks', { TaskName: 'Deep clean' }) }

        before { stub_request(:post, 'https://teams-api.operto.com/api/v1/tasks').to_return({ status: 401, body: expired, headers: json }, found) }

        it 'replays the same body with the renewed token' do
          expect(response.status).to eq(200)
          expect(WebMock).to have_requested(:post, 'https://teams-api.operto.com/api/v1/tasks')
            .with(body: { TaskName: 'Deep clean' }.to_json, headers: { 'Authorization' => 'VRS renewed-token' }).once
        end
      end
    end

    context 'when the envelope reports an expired token' do
      before { stub_request(:get, url).to_return({ status: 200, body: expired, headers: json }, found) }

      it 'renews the token and replays the request once' do
        expect(response.body).to eq(data: [])
        expect(WebMock).to have_requested(:get, url).with(headers: { 'Authorization' => 'VRS renewed-token' }).once
      end
    end

    context 'when Operto limits the rate' do
      before { stub_request(:get, url).to_return(status: 429, body: '{}', headers: json) }

      it 'does not retry' do
        expect(response.status).to eq(429)
        expect(WebMock).to have_requested(:get, url).once
      end
    end

    context 'with a gateway error' do
      before do
        stub_const('Operto::Client::RETRY_OPTIONS', described_class::RETRY_OPTIONS.merge(interval: 0))
        stub_request(:get, url).to_return({ status: 503 }, found)
      end

      it 'retries the read' do
        expect(response.status).to eq(200)
        expect(WebMock).to have_requested(:get, url).twice
      end
    end

    context 'with a gateway error on a POST' do
      subject(:response) { described_class.connection.post('tasks', { TaskName: 'Deep clean' }) }

      before do
        stub_const('Operto::Client::RETRY_OPTIONS', described_class::RETRY_OPTIONS.merge(interval: 0))
        stub_request(:post, 'https://teams-api.operto.com/api/v1/tasks').to_return(status: 503)
      end

      it 'does not retry' do
        expect(response.status).to eq(503)
        expect(WebMock).to have_requested(:post, 'https://teams-api.operto.com/api/v1/tasks').once
      end
    end
  end
end
