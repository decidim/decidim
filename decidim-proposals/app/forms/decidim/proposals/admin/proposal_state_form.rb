# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalStateForm < Decidim::Form
        include Decidim::TranslatableAttributes

        mimic :proposal_state

        translatable_attribute :title, String
        translatable_attribute :announcement_title, String
        attribute :token, String
        attribute :css_class, String

        validates :title, translatable_presence: true
        validates :token, presence: true

        validate :token_uniqueness

        def token_uniqueness
          token = Decidim::Proposals::ProposalState.where(component: current_component, token: attributes.fetch(:token)).where.not(id:)
          errors.add(:token, :taken) if token.exists?
        end
      end
    end
  end
end
