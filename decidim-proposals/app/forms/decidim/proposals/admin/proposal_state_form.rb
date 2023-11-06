# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalStateForm < Decidim::Form
        include Decidim::TranslatableAttributes

        mimic :proposal_state

        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :default, Boolean
        attribute :system, Boolean
        attribute :answerable, Boolean
        attribute :notifiable, Boolean
        attribute :token, String
        attribute :css_class, String
        attribute :include_in_stats, [String]

        validates :title, translatable_presence: true
      end
    end
  end
end
