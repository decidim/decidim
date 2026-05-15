# frozen_string_literal: true

module Decidim
  module Initiatives
    # Service that notifies progress for an initiative
    class ProgressNotifier
      attr_reader :initiative

      def initialize(args = {})
        @initiative = args.fetch(:initiative)
      end

      # PUBLIC: Notifies the support progress of the initiative.
      #
      # Notifies to Initiative's authors about the
      # number of supports received by the initiative.
      def notify
        initiative.committee_members.approved.each do |committee_member|
          Decidim::Initiatives::InitiativesMailer
            .notify_progress(initiative, committee_member.user)
            .deliver_later
        end

        Decidim::Initiatives::InitiativesMailer
          .notify_progress(initiative, initiative.author)
          .deliver_later
      end
    end
  end
end
