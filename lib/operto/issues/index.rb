module Operto
  module Issues
    class Index
      include Operto::Operation

      # @rbs (start_date: ::Date, ?skip: ::Integer, ?take: ::Integer) -> Dry::Monads::Result[::Hash[::Symbol, untyped]]
      def call(start_date:, skip: 0, take: 50)
        query_params = build_query_params(start_date, skip, take)
        response = Operto::Client.connection.get('issues', query_params)
        Operto::Client.handle_response(response) { |body| format_results(body) }
      rescue StandardError => e
        Failure(e)
      end

      private

      def build_query_params(start_date, skip, take)
        page = skip.div(take) + 1

        {
          per_page: take,
          page:,
          closed: 0,
          CreateStartDate: start_date.strftime('%Y%m%d'),
          Sort: 'IssueID desc'
        }
      end

      def format_results(body)
        results = body[:data].map { |issue| format_issue(issue) }

        {
          results:,
          count: body[:total_items] || results.size
        }
      end

      def format_issue(issue)
        issue_type = deduce_issue_type(issue[:IssueType])

        {
          issue_id: issue[:IssueID],
          status_id: issue[:StatusID],
          issue_type:,
          issue_type_name: issue_type.humanize,
          urgent: issue[:Urgent],
          issue: issue[:Issue],
          notes: issue[:Notes],
          staff_notes: issue[:StaffNotes],
          property_id: issue[:PropertyID],
          billable: issue[:Billable],
          create_date: issue[:CreateDate]&.to_date,
          submitted_by_servicer_id: issue[:SubmittedByServicerID],
          images: extract_images(issue[:Images])
        }
      end

      def deduce_issue_type(raw_type)
        raw_type = -1 unless Operto::IssueTypes::ISSUE_TYPES.key?(raw_type)

        Operto::IssueTypes::ISSUE_TYPES[raw_type]
      end

      def extract_images(images)
        Array(images).map do |image|
          { issue_image_id: image[:IssueImageID], image_url: image[:Image] }
        end
      end
    end
  end
end
