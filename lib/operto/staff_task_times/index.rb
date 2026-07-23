module Operto
  module StaffTaskTimes
    class Index
      include Operto::Operation
      include FilteredPagination

      FILTER_MAPPINGS = {
        task_id: 'TaskID',
        staff_id: 'StaffID',
        property_id: 'PropertyID',
        start_date: 'StartDate',
        end_date: 'EndDate'
      }.freeze

      DATE_KEYS = %i[start_date end_date].freeze
      DEFAULT_SORT = 'StaffTaskTimeID desc'.freeze

      # @rbs (?attributes: ::Hash[::Symbol, untyped], ?skip: ::Integer, ?take: ::Integer) -> Dry::Monads::Result[::Hash[::Symbol, untyped]]
      def call(attributes: {}, skip: 0, take: 50)
        validate_arguments!(attributes)

        query_params = build_query_params(attributes, skip, take)
        response = Operto::Client.connection.get('stafftasktimes', query_params)

        Operto::Client.handle_response(response) { |body| format_results(body) }
      rescue StandardError => e
        Failure(e)
      end

      private

      def format_results(body)
        results = body[:data].map do |entry|
          {
            staff_task_time_id: entry[:StaffTaskTimeID],
            staff_id: entry[:StaffID],
            task_id: entry[:TaskID],
            clock_in: entry[:ClockIn]&.to_datetime,
            clock_out: entry[:ClockOut]&.to_datetime,
            note: entry[:Note]
          }
        end

        {
          results:,
          count: body[:total_items] || results.size
        }
      end
    end
  end
end
