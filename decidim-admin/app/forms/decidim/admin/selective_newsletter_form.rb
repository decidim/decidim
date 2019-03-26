# frozen_string_literal: true

module Decidim
  module Admin
    # The form that validates the data to construct a valid Newsletter.
    class SelectiveNewsletterForm < Decidim::Form
      mimic :newsletter

      attribute :participatory_space_types, Array[SelectiveNewsletterParticipatorySpaceTypeForm]
      attribute :scopes, Array[SelectiveNewsletterScopeForm]
      attribute :send_to_participants
      attribute :send_to_followers

      def map_model(newsletter)
        self.scopes = newsletter.organization.scopes.top_level.map do |scope|
          SelectiveNewsletterScopeForm.from_model(scope: scope, newsletter: newsletter)
        end

        self.participatory_space_types = Decidim.participatory_space_manifests.map do |manifest|
          SelectiveNewsletterParticipatorySpaceTypeForm.from_model(manifest: manifest)
        end
      end
    end
  end
end
