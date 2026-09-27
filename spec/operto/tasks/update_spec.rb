RSpec.describe Operto::Tasks::Update do
  subject(:result) { described_class.new.call(task_id:, attributes:) }

  let(:task_id) { 44_683_131 }
  let(:attributes) do
    {
      house_id: '110784',
      reservation_id: '7797550',
      rule_id: '27986',
      name: '[TEST] - Updated task name (no files)',
      description: 'Updated task description',
      start_date: Time.zone.parse('2025-12-09 08:00:00'),
      end_date: Time.zone.parse('2025-12-09 12:00:00')
    }
  end

  context 'with valid arguments', vcr: { cassette_name: 'tasks/update', match_requests_on: %i[method uri body] } do
    it 'returns the task id' do
      expect(result.value!).to eq(task_id:)
    end
  end

  context 'with only a description',
          vcr: { cassette_name: 'tasks/update_description', match_requests_on: %i[method uri body] } do
    let(:task_id) { 39_923_513 }
    let(:attributes) { { description: 'Make up the sofa bed' } }

    it 'sends nothing but the description' do
      expect(result.value!).to eq(task_id:)
    end
  end

  context 'without a task id' do
    let(:task_id) { nil }

    it { expect(result.failure).to be_a(Operto::ArgumentError) }
  end

  context 'with empty attributes' do
    let(:attributes) { {} }

    it { expect(result.failure).to be_a(Operto::ArgumentError) }
  end
end
