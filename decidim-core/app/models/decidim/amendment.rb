# frozen_string_literal: true

module Decidim
  class Amendment < ApplicationRecord
    STATES = { draft: 0, evaluating: 10, accepted: 20, rejected: 30, withdrawn: -1 }.freeze

    belongs_to :amendable, foreign_key: "decidim_amendable_id", foreign_type: "decidim_amendable_type", polymorphic: true
    belongs_to :amender, foreign_key: "decidim_user_id", class_name: "Decidim::User"
    belongs_to :emendation, foreign_key: "decidim_emendation_id", foreign_type: "decidim_emendation_type", polymorphic: true

    validates :state, presence: true, inclusion: { in: STATES.keys.map(&:to_s) }

    enum :state, STATES, default: "draft"

    # Reports the mapped resource type for authorization transfers.
    #
    # @return [String] The resource type as string (i.e. its class name).
    def mapped_resource_type
      decidim_amendable_type
    end

    def promoted?
      return false unless rejected?

      emendation.linked_promoted_resource.present?
    end
  end
end
