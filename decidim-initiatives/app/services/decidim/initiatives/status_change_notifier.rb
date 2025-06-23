# frozen_string_literal: true

module Decidim
  module Initiatives
    # Service that reports changes in initiative status
    class StatusChangeNotifier
      attr_reader :initiative

      def initialize(args = {})
        @initiative = args.fetch(:initiative)
      end

      # PUBLIC
      # Notifies when an initiative has changed its status.
      #
      # * created: Notifies the author that their initiative has been created.
      #
      # * validating: Administrators will be notified about the initiative that
      #   requests technical validation.
      #
      # * published, discarded: Initiative authors will be notified about the
      #   result of the technical validation process.
      #
      # * rejected, accepted: Initiative's authors will be
      #   notified about the result of the initiative.
      def notify
        notify_initiative_creation if initiative.created?
        notify_validating_initiative if initiative.validating?
        notify_validating_result if initiative.published? || initiative.discarded?
        notify_support_result if initiative.rejected? || initiative.accepted?
      end

      private

      def notify_initiative_creation
        Decidim::Initiatives::InitiativesMailer
          .notify_creation(initiative)
          .deliver_later
      end

      # Does nothing
      def notify_validating_initiative
        # It has been moved into SendInitiativeToTechnicalValidation command as a standard notification
        # It would be great to move the functionality of this class, which is invoked on Initiative#after_save,
        # to the corresponding commands to follow the architecture of Decidim.
      end

      def notify_validating_result
        initiative.committee_members.approved.each do |committee_member|
          Decidim::Initiatives::InitiativesMailer
            .notify_state_change(initiative, committee_member.user)
            .deliver_later
        end

        Decidim::Initiatives::InitiativesMailer
          .notify_state_change(initiative, initiative.author)
          .deliver_later
      end

      def notify_support_result
        Decidim::Initiatives::InitiativesMailer
          .notify_state_change(initiative, initiative.author)
          .deliver_later

        initiative.committee_members.approved.each do |committee_member|
          Decidim::Initiatives::InitiativesMailer
            .notify_state_change(initiative, committee_member.user)
            .deliver_later
        end

        Decidim::Initiatives::InitiativesMailer
          .notify_state_change(initiative, initiative.author)
          .deliver_later
      end
    end
  end
end
