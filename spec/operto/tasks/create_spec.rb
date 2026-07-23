RSpec.describe Operto::Tasks::Create do
  subject(:result) { described_class.new.call(attributes:) }

  let(:attributes) do
    {
      house_id: '110784',
      reservation_id: '7797550',
      name: '[TEST] - API spec create',
      description: 'Detailed test task',
      start_date: Time.zone.parse('2025-12-01 09:00:00'),
      end_date: Time.zone.parse('2025-12-02 09:00:00'),
      rule_id: '27986'
    }
  end

  context 'with valid arguments', vcr: { cassette_name: 'tasks/create' } do
    it 'creates the task and returns its id' do
      expect(result.value!).to eq(task_id: 44_683_131)
    end
  end

  context 'without a required key' do
    let(:attributes) { super().except(:house_id) }

    it 'fails with an argument error before any request' do
      expect(result.failure).to be_a(Operto::ArgumentError)
    end
  end
end
