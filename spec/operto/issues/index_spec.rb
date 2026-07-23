RSpec.describe Operto::Issues::Index do
  subject(:result) { described_class.new.call(start_date: Date.new(2026, 3, 5), skip: 0, take: 2) }

  context 'with valid arguments', vcr: { cassette_name: 'issues/index' } do
    it 'returns mapped issues' do
      expect(result.value!).to include(
        results: array_including(
          a_hash_including(
            issue_id: 2_160_901,
            status_id: 0,
            issue_type: 'maintenance',
            issue_type_name: 'Maintenance',
            urgent: true,
            property_id: 123_810,
            create_date: Date.new(2026, 4, 3),
            submitted_by_servicer_id: 25_520
          )
        ),
        count: 2
      )
    end

    it 'maps every issue to a known type' do
      types = result.value![:results].pluck(:issue_type)
      expect(types).to all(be_in(Operto::IssueTypes::ISSUE_TYPES.values))
    end
  end
end
