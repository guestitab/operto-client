RSpec.describe Operto::StaffTasks::Destroy do
  subject(:result) { described_class.new.call(staff_task_id:) }

  let(:staff_task_id) { 123_456 }

  context 'with valid arguments', vcr: { cassette_name: 'staff_tasks/destroy' } do
    it { expect(result.value!).to be(true) }
  end

  context 'when staff_task_id is missing' do
    let(:staff_task_id) { nil }

    it { expect(result.failure).to be_a(Operto::ArgumentError) }
  end

  context 'when Operto returns an error' do
    before do
      stub_request(:delete, "https://teams-api.operto.com/api/v1/stafftasks/#{staff_task_id}")
        .to_return(
          status: 404,
          body: { ReasonCode: 404, ReasonText: 'Staff task not found' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it { expect(result.failure.message).to eq('404: Staff task not found') }
  end
end
