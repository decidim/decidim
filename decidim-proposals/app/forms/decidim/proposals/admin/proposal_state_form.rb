# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalStateForm < Decidim::Form
        include Decidim::TranslatableAttributes

        mimic :proposal_state

        translatable_attribute :title, String
        translatable_attribute :description, String
        translatable_attribute :announcement_title, String
        attribute :default, Boolean
        attribute :system, Boolean
        attribute :answerable, Boolean
        attribute :notifiable, Boolean
        attribute :gamified, Boolean
        attribute :token, String
        attribute :css_class, String
        attribute :include_in_stats, [String]

        validates :title, translatable_presence: true
        validates :token, presence: true

        validate :token_uniqueness

        def token_uniqueness
          token = Decidim::CustomProposalStates::ProposalState.where(component: current_component, token: attributes.fetch(:token))
          errors.add(:token, :taken) if token.exists?
        end
      end
    end
  end
end
