module Operto
  module Tasks
    class Show
      include Operto::Operation
      include Shared

      # @rbs (task_id: ::String | ::Integer) -> Dry::Monads::Result[::Hash[::Symbol, untyped]]
      def call(task_id:)
        argument! task_id: :required if task_id.blank?

        response = Operto::Client.connection.get("tasks/#{task_id}")

        Operto::Client.handle_response(response) do |body|
          # A missing task comes back as an empty list, not a 404.
          task = body[:data]&.first
          raise Operto::NotFoundError, "Task #{task_id} not found" unless task

          normalize_task(task)
        end
      rescue StandardError => e
        Failure(e)
      end
    end
  end
end
