# frozen_string_literal: true

module Decidim
  module Budgets
    class SerializerManager
      EVENT_NAME = "decidim.budgets.project_serializeable"

      attr_accessor :serializeable
      attr_reader :project

      def initialize(serializeable, project)
        @serializeable = serializeable
        @project = project
      end

      def manage
        ActiveSupport::Notifications.publish(
          EVENT_NAME,
          klass: self,
          serializeable: serializeable,
          project: project
        )
        serializeable
      end

      def self.subscribe(&block)
        ActiveSupport::Notifications.subscribe(EVENT_NAME) do |_event_name, data|
          block.call(data)
        end
      end

      # def self.publish(serializeable)
      #   Rails.logger.info "\n\n\n\n\n\n\n IN MANAGER 1 \n\n\n\n\n\n\n"
      #   @serializeable = serializeable
      #   Rails.logger.info "\n\n\n\n\n\n\n IN MANAGER 2 \n\n\n\n\n\n\n"
      #   ActiveSupport::Notifications.publish(
      #     EVENT_NAME,
      #     klass: self,
      #     serializeable: serializeable
      #   )
      #   Rails.logger.info "\n\n\n\n\n\n\n IN MANAGER 3 \n\n\n\n\n\n\n"
      #   serializeable
      # end

      # def self.finish_publish(serializeable)
      #   ActiveSupport::Notifications.publish(
      #     FINISH_EVENT_NAME,
      #     klass: self,
      #     serializeable: serializeable
      #   )
      # end

      # def self.finish_subscribe(&block)

      # end
    end
  end
end
