RSpec.describe Operto::StaffTaskTimes::Index do
  subject(:result) { described_class.new.call(attributes:, skip: 0, take: 50) }

  let(:attributes) { { task_id: 17_094_481 } }

  context 'with valid arguments', vcr: { cassette_name: 'staff_task_times/index' } do
    it 'returns mapped staff task times' do
      expect(result.value!).to include(
        results: array_including(
          a_hash_including(
            staff_task_time_id: 2_802_102,
            staff_id: 25_525,
            task_id: 17_094_481,
            clock_in: DateTime.parse('2023-08-14 13:35:00'),
            clock_out: DateTime.parse('2023-08-14 14:35:00'),
            note: 'Sample note.'
          )
        ),
        count: 3
      )
    end
  end

  context 'with a blank value' do
    let(:attributes) { { task_id: nil } }

    it { expect(result.failure).to be_a(Operto::ArgumentError) }
  end
end
