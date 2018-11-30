# frozen_string_literal: true

module Decidim
  class Amendment < ApplicationRecord
    belongs_to :amendable, foreign_key: "decidim_amendable_id", foreign_type: "decidim_amendable_type", polymorphic: true
    belongs_to :amender, foreign_key: "decidim_user_id", class_name: "Decidim::User"
    belongs_to :emendation, foreign_key: "decidim_emendation_id", foreign_type: "decidim_emendation_type", polymorphic: true

    STATES = %w(evaluating accepted rejected withdrawn).freeze

    def evaluating?
      state == "evaluating"
    end

    validates :amendable, :amender, :emendation, presence: true
  end
end
