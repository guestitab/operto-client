module Operto
  module Issues
    class Close
      include Operto::Operation

      # @rbs (issue_id: ::Integer | ::String) -> Dry::Monads::Result[::Hash[::Symbol, untyped]]
      def call(issue_id:)
        argument! issue_id: :required if issue_id.blank?

        response = Operto::Client.connection.post('issues', close_body(issue_id))
        Operto::Client.handle_response(response) { |body| { issue_id: body.dig(:Data, :IssueID) } }
      rescue StandardError => e
        Failure(e)
      end

      private

      def close_body(issue_id)
        {
          request: {
            IssueID: issue_id,
            Update: true,
            ClosedDate: Date.current.strftime('%Y%m%d')
          }.to_json
        }
      end
    end
  end
end
