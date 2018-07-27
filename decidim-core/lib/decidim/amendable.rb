# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to amendable resources.
  module Amendable
    extend ActiveSupport::Concern

    included do
      has_many :amendments, as: :amendable, foreign_key: "decidim_amendable_id", foreign_type: "decidim_amendable_type", class_name: "Decidim::Amendment"

      # resource.emendations : resources that have amend the resource
      has_many :emendations, through: :amendments, source: :emendation, source_type: self.name, inverse_of: :emendations

      # resource.amenders : users that have amended the resource
      has_many :amenders, through: :amendments, source: :amender

      # resource.amended : the original resource that was amended
      has_one :amend, as: :amendable, foreign_key: "decidim_emendation_id", foreign_type: "decidim_emendation_type", class_name: "Decidim::Amendment"
      has_one :amendable, through: :amend, source: :amendable, source_type: self.name

    end

    def emendation?
      true if amendable.present?
    end

    def amendable?
      return false if emendation?
      component.settings.amendments_enabled
    end


    def emendation_state
      Decidim::Amendment.find_by(emendation: id).state if emendation?
    end

    def state
      emendation_state
    end
  end
end
