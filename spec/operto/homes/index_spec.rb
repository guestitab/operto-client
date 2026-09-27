RSpec.describe Operto::Homes::Index do
  subject(:result) { described_class.new.call(skip: 0, take: 2) }

  context 'with valid arguments', vcr: { cassette_name: 'homes/index' } do
    it 'returns normalized homes' do
      expect(result.value!).to include(
        results: array_including(
          a_hash_including(
            property_id: 110_784,
            property_name: 'Sample Property',
            integration_company_property_id: 'aaaa1111bbbb2222cccc3333',
            created_at: Date.new(2023, 3, 24)
          )
        ),
        count: 823
      )
    end
  end

  context 'with an unparseable create date' do
    before do
      stub_request(:get, 'https://teams-api.operto.com/api/v1/properties?page=1&per_page=2')
        .to_return(
          body: { data: [{ PropertyID: 110_784, CreateDate: 'n/a' }] }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'keeps the raw value' do
      expect(result.value![:results].first[:created_at]).to eq('n/a')
    end
  end
end
