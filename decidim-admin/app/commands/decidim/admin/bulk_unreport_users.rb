# frozen_string_literal: true

module Decidim
  module Admin
    class BulkUnreportUsers < Decidim::Command
      # Public: Initializes the command.
      #
      # current_user - the user that performs the action
      # reportables - all Decidim::Reportable selected by current_user
      def initialize(current_user, reportables)
        @current_user = current_user
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

        bulk_unreport_users!
        create_action_log if first_unreported

        broadcast(:ok, **result)
      end

      private

      attr_reader :reportables, :current_user, :result, :first_unreported

      def create_action_log
        Decidim::ActionLogger.log(
          "bulk_ignore",
          current_user,
          first_unreported,
          nil,
          extra: {
            unreported:,
            reportable_type: first_unreported.class.name
          }
        )
      end

      def unreported
        @unreported ||= result[:ok].to_h { |reportable| [reportable.id, reportable.name] }
      end

      def bulk_unreport_users!
        reportables.each do |reportable|
          next unless reportable

          if reportable.respond_to?(:organization) && reportable.organization != current_user.organization
            result[:ok] << reportable
            next
          end
          reportable.user_moderation.destroy!
          result[:ok] << reportable
          @first_unreported ||= reportable
        rescue ActiveRecord::RecordInvalid
          result[:ko] << reportable
        end
      end
    end
  end
end
