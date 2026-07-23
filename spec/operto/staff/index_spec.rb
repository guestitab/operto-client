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
end
