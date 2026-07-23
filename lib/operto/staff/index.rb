module Operto
  module Staff
    class Index
      include Operto::Operation

      DEFAULT_PAGE_SIZE = 100

      # @rbs (?skip: ::Integer, ?take: ::Integer) -> Dry::Monads::Result[::Hash[::Symbol, untyped]]
      def call(skip: 0, take: DEFAULT_PAGE_SIZE)
        query_params = build_query_params(skip, take)
        response = Operto::Client.connection.get('staff', query_params)
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
        results = body.fetch(:data, []).map { |staff| format_staff(staff) }

        {
          results:,
          count: body[:total_items] || results.size
        }
      end

      def format_staff(staff)
        {
          staff_id: staff[:StaffID],
          name: staff[:Name],
          abbreviation: staff[:Abbreviation],
          email: staff[:Email]&.downcase,
          phone: staff[:Phone],
          country_id: staff[:CountryID],
          active: staff[:Active],
          created_at: parse_date(staff[:CreateDate])
        }
      end

      def parse_date(value)
        return if value.blank?

        Date.parse(value.to_s)
      rescue ArgumentError
        value
      end
    end
  end
end
