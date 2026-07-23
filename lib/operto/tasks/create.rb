module Operto
  module Tasks
    class Create
      include Operto::Operation
      include Shared

      # @rbs (attributes: ::Hash[::Symbol, untyped]) -> Dry::Monads::Result[::Hash[::Symbol, untyped]]
      def call(attributes:)
        validate_arguments!(attributes)

        request_attributes = prepare_attributes(attributes)
        response = Operto::Client.connection.post('tasks', request_attributes)

        handle_task_response(response)
      rescue StandardError => e
        Failure(e)
      end

      private

      def validate_arguments!(attributes)
        argument! attributes: :invalid unless attributes.is_a?(Hash) && attributes.present?

        required_keys.each do |key|
          required_attribute!(key) if attributes[key].blank?
        end
      end

      def required_keys
        %i[house_id name start_date end_date rule_id]
      end
    end
  end
end
