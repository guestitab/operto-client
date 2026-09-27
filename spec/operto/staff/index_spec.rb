RSpec.describe Operto::Staff::Index do
  subject(:result) { described_class.new.call(skip: 0, take: 10) }

  context 'with valid arguments', vcr: { cassette_name: 'staff/index' } do
    it 'returns mapped staff' do
      expect(result.value!).to include(
        results: array_including(
          a_hash_including(
            staff_id: 41_295,
            name: 'John Appleseed',
            email: 'john.appleseed@example.com',
            active: true
          )
        ),
        count: 3
      )
    end
  end

  context 'with an unparseable create date' do
    before do
      stub_request(:get, 'https://teams-api.operto.com/api/v1/staff?page=1&per_page=10')
        .to_return(
          body: { data: [{ StaffID: 41_295, CreateDate: 'n/a' }] }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'keeps the raw value' do
      expect(result.value![:results].first[:created_at]).to eq('n/a')
    end
  end
end
