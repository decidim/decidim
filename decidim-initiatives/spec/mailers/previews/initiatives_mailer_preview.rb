# frozen_string_literal: true

module Decidim
  module Initiatives
    class InitiativesMailerPreview < ActionMailer::Preview
      def notify_creation
        initiative = Decidim::Initiative.first
        Decidim::Initiatives::InitiativesMailer.notify_creation(initiative)
      end

      def notify_progress
        initiative = Decidim::Initiative.first
        Decidim::Initiatives::InitiativesMailer.notify_progress(initiative, initiative.author)
      end

      def notify_state_change_to_published
        initiative = Decidim::Initiative.first
        initiative.state = "published"
        Decidim::Initiatives::InitiativesMailer.notify_state_change(initiative, initiative.author)
      end

      def notify_state_change_to_discarded
        initiative = Decidim::Initiative.first
        initiative.state = "discarded"
        Decidim::Initiatives::InitiativesMailer.notify_state_change(initiative, initiative.author)
      end

      def notify_state_change_to_accepted
        initiative = Decidim::Initiative.first
        initiative.state = "accepted"
        Decidim::Initiatives::InitiativesMailer.notify_state_change(initiative, initiative.author)
      end

      def notify_state_change_to_rejected
        initiative = Decidim::Initiative.first
        initiative.state = "rejected"
        Decidim::Initiatives::InitiativesMailer.notify_state_change(initiative, initiative.author)
      end
    end
  end
end
