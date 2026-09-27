RSpec.describe Operto::Tasks::Index do
  subject(:result) { described_class.new.call(attributes:, skip: 0, take: 10) }

  let(:attributes) { { property_id: '111036' } }

  context 'with valid arguments', vcr: { cassette_name: 'tasks/index' } do
    it 'returns mapped task results' do
      expect(result.value!).to include(
        results: [
          a_hash_including(
            task_id: 39_923_513,
            property_id: 111_036,
            property_booking_id: 11_111_111,
            rule_id: 20_574,
            name: 'Check Out Clean',
            description: nil,
            starts_at: Time.zone.parse('2026-10-15 10:00'),
            due_at: Time.zone.parse('2026-10-15 15:30'),
            active: true,
            completed: false,
            approved_at: nil,
            completed_at: nil,
            staff: [a_hash_including(staff_id: 40_277, name: 'HC - Jane Doe', email: 'jane.doe@example.com')]
          )
        ],
        count: 189
      )
    end
  end

  context 'with a blank value' do
    let(:attributes) { { property_id: nil } }

    it { expect(result.failure).to be_a(Operto::ArgumentError) }
  end

  context 'with an unknown key' do
    let(:attributes) { { property_id: '111036', invalid_key: 'value' } }

    it { expect(result.failure).to be_a(Operto::ArgumentError) }
  end
end
