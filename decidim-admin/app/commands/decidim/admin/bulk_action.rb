# frozen_string_literal: true

module Decidim
  module Admin
    class BulkAction < Decidim::Command
      # Public: Initializes the command.
      #
      # current_user - the user that performs the action
      # action - can be hide, unhide and unreport resources
      # selected_moderations - all resources selected by current_user
      def initialize(current_user, action, selected_moderations)
        @current_user = current_user
        @action = action
        @selected_moderations = selected_moderations
        @result = { ok: [], ko: [] }
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is not reported
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if selected_moderations.blank?

        process_reportables
        create_action_log if selected_moderations.first.reportable

        broadcast(:ok, **result)
      end

      private

      attr_reader :action, :selected_moderations, :current_user, :result, :with_admin_log

      def create_action_log
        action_log_type = "bulk_#{action}"

        Decidim::ActionLogger.log(
          action_log_type,
          current_user,
          selected_moderations.first,
          nil,
          extra: {
            reported_content:,
            reported_count: result[:ok].count
          }
        )
      end

      def reported_content
        @reported_content ||= result[:ok].group_by(&:decidim_reportable_type).to_h do |klass, moderations|
          [
            klass.split("::").last.downcase.pluralize,
            moderations.to_h { |moderation| [moderation.reportable.id, moderation.title] }
          ]
        end
      end

      def process_reportables
        selected_moderations.each do |moderation|
          next unless moderation

          if moderation.respond_to?(:organization) && moderation.organization != current_user.organization
            result[:ko] << moderation
            next
          end
          command.call(moderation.reportable, current_user, with_admin_log: false) do
            on(:ok) do
              result[:ok] << moderation
            end
            on(:invalid) do
              result[:ko] << moderation
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
