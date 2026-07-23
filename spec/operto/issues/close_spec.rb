RSpec.describe Operto::Issues::Close do
  subject(:result) { described_class.new.call(issue_id:) }

  let(:issue_id) { '2181372' }

  context 'with valid arguments', vcr: { cassette_name: 'issues/close' } do
    around { |example| travel_to(Date.new(2026, 4, 15)) { example.run } }

    it { expect(result.value!).to include(issue_id:) }
  end

  context 'without an issue id' do
    let(:issue_id) { nil }

    it { expect(result.failure).to be_a(Operto::ArgumentError) }
  end
end
