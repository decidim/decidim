# frozen_string_literal: true

module Decidim
  module Admin
    class BulkAction < Decidim::Command
      # Public: Initializes the command.

      def initialize(user, action, reportables)
        @user = user
        @action = action
        @reportables = reportables
        @result = { ok: [], ko: [] }
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is not reported
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if reportables.blank?

        bulk_action!
        create_action_log

        broadcast(:ok, **result)
      end

      private

      attr_reader :action, :reportables, :user, :result

      def create_action_log
        action_log_type = case action
                          when "hide"
                            "bulk_hide_content"
                          when "unreport"
                            "bulk_unreport_users"
                          when "unhide"
                            "bulk_unhide_content"
                          end

        Decidim::ActionLogger.log(
          action_log_type,
          user,
          user,
          nil,
          reported_content: extra_log_info
        )
      end

      def extra_log_info
        @extra_log_info ||= result[:ok].to_h { |reportable| [reportable.id, reportable.class.name] }
      end

      def bulk_action!
        reportables.each do |reportable|
          next unless reportable

          if reportable.respond_to?(:organization) && reportable.organization != user.organization
            result[:ok] << reportable
            next
          end
          command.call(reportable, user) do
            on(:ok) do
              result[:ok] << reportable
            end
            on(:invalid) do
              result[:ok] << reportable
            end
          end
        end
      end

      def command
        case action
        when "hide"
          Admin::HideResource
        when "unreport"
          Admin::BulkUnreportContent
        when "unhide"
          Admin::BulkUnhideContent
        end
      end
    end
  end
end
