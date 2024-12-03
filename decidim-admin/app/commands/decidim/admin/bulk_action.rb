# frozen_string_literal: true

module Decidim
  module Admin
    class BulkAction < Decidim::Command
      # Public: Initializes the command.

      def initialize(user, action, moderations)
        @user = user
        @action = action
        @moderations = moderations
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

        process_reportables
        create_action_log if user

        broadcast(:ok, **result)
      end

      private

      attr_reader :action, :reportables, :user, :result

      def create_action_log
        action_log_type = "bulk_#{action}"

        Decidim::ActionLogger.log(
          action_log_type,
          user,
          moderations.first.reportable,
          nil,
          extra: {
            reported_content:,
            reportable_type: reported_content.values
          }
        )
      end

      def reported_content
        @reported_content ||= result[:ok].to_h { |moderation| [moderation.reportable.id, moderation.title] }
      end

      def bulk_action!
        reportables.each do |reportable|
          next unless reportable

          if reportable.respond_to?(:organization) && reportable.organization != user.organization
            result[:ko] << reportable
            next
          end
          command.call(reportable, user) do
            on(:ok) do
              result[:ok] << reportable
            end
            on(:invalid) do
              result[:ko] << reportable
            end
          end
        end
      end

      def command
        case action
        when "hide"
          Admin::HideResource
        when "unreport"
          Admin::UnreportResource
        when "unhide"
          Admin::UnhideResource
        end
      end
    end
  end
end
