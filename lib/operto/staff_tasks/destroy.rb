module Operto
  module StaffTasks
    class Destroy
      include Operto::Operation

      # @rbs (staff_task_id: ::String) -> Dry::Monads::Result[bool]
      def call(staff_task_id:)
        validate_arguments!(staff_task_id)

        response = Operto::Client.connection.delete("stafftasks/#{staff_task_id}")
        Operto::Client.handle_response(response)
      rescue StandardError => e
        Failure(e)
      end

      private

      def validate_arguments!(staff_task_id)
        argument! staff_task_id: :required if staff_task_id.blank?
      end
    end
  end
end
