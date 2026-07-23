module Operto
  module Tasks
    module Shared
      private

      def prepare_attributes(attrs)
        base_attrs = {
          PropertyID: attrs[:house_id],
          TaskRuleID: attrs[:rule_id],
          TaskName: attrs[:name],
          TaskDescription: attrs[:description].presence || '-'
        }.compact_blank

        base_attrs.merge(datetime_attributes(attrs))
      end

      def datetime_attributes(attrs)
        h = {}

        start_date = parse_datetime(attrs[:start_date])
        h[:TaskDate] = h[:TaskStartDate] = as_date(start_date)
        h[:TaskTime] = h[:TaskStartTime] = start_date.hour

        complete_by = parse_datetime(attrs[:end_date])
        h[:TaskCompleteByDate] = as_date(complete_by)
        h[:TaskCompleteByTime] = complete_by.hour

        h
      end

      def parse_datetime(value)
        Time.zone.parse(value.to_s)
      end

      def as_date(value)
        value.strftime('%Y-%m-%d')
      end

      def handle_task_response(response)
        Operto::Client.handle_response(response) { |body| { task_id: body[:TaskID] } }
      end
    end
  end
end
