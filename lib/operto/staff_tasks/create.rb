module Operto
  module StaffTasks
    class Create
      include Operto::Operation

      # @rbs (task_id: ::String, staff_id: ::String, property_id: ::String) -> Dry::Monads::Result[::Hash[::Symbol, untyped]]
      def call(task_id:, staff_id:, property_id:)
        validate_arguments!(task_id, staff_id, property_id)

        response = Operto::Client.connection.post('stafftasks', request_attributes(task_id, staff_id, property_id))
        Operto::Client.handle_response(response) { |body| { staff_task_id: body[:StaffTaskID] } }
      rescue StandardError => e
        Failure(e)
      end

      private

      def validate_arguments!(task_id, staff_id, property_id)
        argument! task_id: :required if task_id.blank?
        argument! staff_id: :required if staff_id.blank?
        argument! property_id: :required if property_id.blank?
      end

      def request_attributes(task_id, staff_id, property_id)
        {
          TaskID: task_id,
          StaffID: staff_id,
          PropertyID: property_id
        }
      end
    end
  end
end
