# frozen_string_literal: true

module Decidim
  module Admin
    # The form that validates the data to construct a valid Newsletter.
    class SelectRecipientsNewsletterForm < Decidim::Form
      mimic :newsletter

      attribute :participatory_spaces, Array[SelectRecipientsNewsletterParticipatorySpaceForm]
      attribute :scopes, Array[SelectRecipientsNewsletterScopeForm]
      attribute :send_to_participants
      attribute :send_to_followers

      def map_model(newsletter)
        self.scopes = newsletter.organization.scopes.top_level.map do |scope|
          SelectRecipientsNewsletterScopeForm.from_model(scope: scope, newsletter: newsletter)
        end
      end
    end
  end
end
