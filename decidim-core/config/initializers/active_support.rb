# frozen_string_literal: true

ActiveSupport::Notifications.subscribe "render_cell.action_view" do |name, started, finished, unique_id, data|
  event = ActiveSupport::Notifications::Event.new(name, started, finished, unique_id, data)
  message = "  Rendered cell #{event.payload[:identifier]} (#{event.duration.round(1)}ms)"
  Rails.logger.info(message)
end
