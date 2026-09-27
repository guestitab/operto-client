RSpec.describe Operto::Tasks::Show do
  subject(:result) { described_class.new.call(task_id:) }

  let(:task_id) { 39_923_514 }

  context 'with an existing task', vcr: { cassette_name: 'tasks/show' } do
    it 'returns the normalized task' do
      expect(result.value!).to include(
        task_id:,
        rule_id: 20_574,
        description: 'Vacuum the balcony',
        starts_at: Time.zone.parse('2026-10-15 10:00'),
        completed: true,
        completed_at: DateTime.parse('2026-10-15 13:40:44')
      )
    end
  end

  context 'with a missing task', vcr: { cassette_name: 'tasks/show_missing' } do
    let(:task_id) { 39_923_599 }

    it { expect(result.failure).to be_a(Operto::NotFoundError) }
  end

  context 'without a task id' do
    let(:task_id) { nil }

    it { expect(result.failure).to be_a(Operto::ArgumentError) }
  end
end
