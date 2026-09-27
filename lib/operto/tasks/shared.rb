module Operto
  module Tasks
    module Shared
      COMPLETED_VALUES = [true, '1', 1].freeze

      private

      # Only the given keys travel, so an update never resets what the caller left out.
      def request_attributes(attrs)
        request = { PropertyID: attrs[:house_id], TaskRuleID: attrs[:rule_id], TaskName: attrs[:name] }.compact_blank
        request[:TaskDescription] = attrs[:description].presence || '-' if attrs.key?(:description)
        request.merge!(start_attributes(attrs[:start_date])) if attrs[:start_date]
        request.merge!(complete_by_attributes(attrs[:end_date])) if attrs[:end_date]
        request
      end

      def start_attributes(value)
        start_date = parse_datetime(value)
        date = as_date(start_date)

        { TaskStartDate: date, TaskDate: date, TaskStartTime: start_date.hour, TaskTime: start_date.hour }
      end

      def complete_by_attributes(value)
        complete_by = parse_datetime(value)

        { TaskCompleteByDate: as_date(complete_by), TaskCompleteByTime: complete_by.hour }
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

      # The list and the single-task read send "10:00" and "0"/"1"; a write echoes 10 and false.
      def normalize_task(task)
        {
          task_id: task[:TaskID],
          property_id: task[:PropertyID],
          property_booking_id: task[:PropertyBookingID],
          rule_id: task[:TaskRuleID],
          name: task[:TaskName]&.strip,
          description: task[:TaskDescription],
          **task_schedule(task),
          **task_progress(task)
        }
      end

      def task_schedule(task)
        {
          starts_at: task_time(task[:TaskStartDate] || task[:TaskDate], task[:TaskStartTime] || task[:TaskTime]),
          due_at: task_time(task[:TaskCompleteByDate], task[:TaskCompleteByTime])
        }
      end

      def task_progress(task)
        {
          active: task[:TaskActive] != false,
          completed: COMPLETED_VALUES.include?(task[:Completed]),
          approved_at: task[:ApprovedDate]&.to_datetime,
          completed_at: task[:CompleteConfirmedDate]&.to_datetime,
          staff: extract_staff(task[:Staff])
        }
      end

      def task_time(date, time)
        return if date.blank?

        hour, minute = time.to_s.split(':')
        Time.zone.parse(date.to_s).change(hour: hour.to_i, min: minute.to_i)
      end

      def extract_staff(staff)
        Array(staff).map do |member|
          { staff_id: member[:StaffID], name: member[:Name], email: member[:Email]&.downcase, active: member[:Active] }
        end
      end
    end
  end
end
