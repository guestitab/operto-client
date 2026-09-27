module Operto
  module Tasks
    class Index
      include Operto::Operation
      include FilteredPagination
      include Shared

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
        results = body[:data].map { |task| normalize_task(task) }

        {
          results:,
          count: body[:total_items] || results.size
        }
      end
    end
  end
end
