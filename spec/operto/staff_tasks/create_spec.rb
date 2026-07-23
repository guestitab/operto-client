RSpec.describe Operto::StaffTasks::Create do
  subject(:result) { described_class.new.call(task_id:, staff_id:, property_id:) }

  let(:task_id) { '44683131' }
  let(:staff_id) { '41295' }
  let(:property_id) { '110784' }

  context 'with valid arguments', vcr: { cassette_name: 'staff_tasks/create' } do
    it { expect(result.value!).to eq(staff_task_id: 123_456) }
  end

  context 'when a required argument is missing' do
    let(:task_id) { nil }

    it { expect(result.failure).to be_a(Operto::ArgumentError) }
  end

  context 'when Operto returns an error' do
    before do
      stub_request(:post, 'https://teams-api.operto.com/api/v1/stafftasks')
        .to_return(
          status: 400,
          body: { ReasonCode: 400, ReasonText: 'Invalid task' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it { expect(result.failure.message).to eq('400: Invalid task') }
  end
end
