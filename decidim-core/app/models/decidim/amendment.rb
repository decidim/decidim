# frozen_string_literal: true

module Decidim
  class Amendment < ApplicationRecord
    # include Decidim::DataPortability ??

    belongs_to :amendable, foreign_key: "decidim_amendable_id", foreign_type: "decidim_amendable_type", polymorphic: true
    belongs_to :amender, foreign_key: "decidim_user_id", class_name: "Decidim::User"
    belongs_to :emendation, foreign_key: "decidim_emendation_id", foreign_type: "decidim_emendation_type", polymorphic: true

    STATES = %w(evaluating accepted rejected).freeze

    def evaluating?
      state == "evaluating"
    end

    # validates :amender, uniqueness: { scope: [:amendable] }

    # def self.export_serializer
    #   Decidim::DataPortabilitySerializers::DataPortabilityAmendSerializer
    # end
  end
end
