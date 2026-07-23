module Operto
  module Homes
    class Index
      include Operto::Operation

      DEFAULT_PAGE_SIZE = 25

      # @rbs (?skip: ::Integer, ?take: ::Integer) -> Dry::Monads::Result[::Hash[::Symbol, untyped]]
      def call(skip: 0, take: DEFAULT_PAGE_SIZE)
        query_params = build_query_params(skip, take)
        response = Operto::Client.connection.get('properties', query_params)
        Operto::Client.handle_response(response) { |body| format_results(body) }
      rescue StandardError => e
        Failure(e)
      end

      private

      def build_query_params(skip, take)
        page = skip.div(take) + 1

        {
          per_page: take,
          page:
        }
      end

      def format_results(body)
        results = body.fetch(:data, []).map { |home| format_home(home) }

        formatted = body.dup
        formatted[:results] = results
        formatted[:count] = body[:total_items] || results.size
        formatted
      end

      def format_home(home)
        normalized = home.transform_keys { |key| key.to_s.underscore.to_sym }

        normalized.merge(
          created_at: parse_date(normalized[:create_date])
        )
      end

      def parse_date(value)
        return if value.blank?

        Date.strptime(value.to_s, '%Y%m%d')
      rescue ArgumentError
        value
      end
    end
  end
end
