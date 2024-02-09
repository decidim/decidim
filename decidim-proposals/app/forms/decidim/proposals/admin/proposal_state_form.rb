# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalStateForm < Decidim::Form
        include Decidim::TranslatableAttributes

        mimic :proposal_state

        translatable_attribute :title, String
        translatable_attribute :announcement_title, String
        attribute :bg_color, String
        attribute :text_color, String

        validates :title, translatable_presence: true
        validates :bg_color, presence: true
        validates :text_color, presence: true
      end
    end
  end
end
