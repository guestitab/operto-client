module Operto
  module Tasks
    class Index
      include Operto::Operation
      include FilteredPagination

      FILTER_MAPPINGS = {
        property_id: 'PropertyID',
        task_rule_id: 'TaskRuleID',
        approved_start_date: 'ApprovedStartDate',
        approved_end_date: 'ApprovedEndDate',
        completed_start_date: 'CompletedStartDate',
        completed_end_date: 'CompletedEndDate',
        task_start_date: 'TaskStartDate',
        task_end_date: 'TaskEndDate'
      }.freeze

      DATE_KEYS = %i[
        approved_start_date approved_end_date
        completed_start_date completed_end_date
        task_start_date task_end_date
      ].freeze

      DEFAULT_SORT = 'TaskID desc'.freeze

      # @rbs (?attributes: ::Hash[::Symbol, untyped], ?skip: ::Integer, ?take: ::Integer) -> Dry::Monads::Result[::Hash[::Symbol, untyped]]
      def call(attributes: {}, skip: 0, take: 50)
        validate_arguments!(attributes)

        query_params = build_query_params(attributes, skip, take)
        response = Operto::Client.connection.get('tasks', query_params)
        Operto::Client.handle_response(response) { |body| format_results(body) }
      rescue StandardError => e
        Failure(e)
      end

      private

      def format_results(body)
        results = body[:data].map do |task|
          {
            task_id: task[:TaskID],
            property_id: task[:PropertyID],
            approved_at: task[:ApprovedDate]&.to_datetime,
            completed_at: task[:CompleteConfirmedDate]&.to_datetime,
            staff: extract_staff(task[:Staff])
          }
        end

        {
          results:,
          count: body[:total_items] || results.size
        }
      end

      def extract_staff(staff_array)
        return [] if staff_array.blank?

        staff_array.map do |staff|
          {
            staff_id: staff[:StaffID],
            name: staff[:Name],
            email: staff[:Email]&.downcase,
            active: staff[:Active]
          }
        end
      end
    end
  end
end
