module Operto
  module Tasks
    class Update
      include Operto::Operation
      include Shared

      # @rbs (task_id: ::String | ::Integer, attributes: ::Hash[::Symbol, untyped]) -> Dry::Monads::Result[::Hash[::Symbol, untyped]]
      def call(task_id:, attributes:)
        validate_arguments!(task_id, attributes)

        response = Operto::Client.connection.put("tasks/#{task_id}", request_attributes(attributes))

        handle_task_response(response)
      rescue StandardError => e
        Failure(e)
      end

      private

      def validate_arguments!(task_id, attributes)
        argument! task_id: :required if task_id.blank?
        argument! attributes: :invalid if attributes.blank?
      end
    end
  end
end
