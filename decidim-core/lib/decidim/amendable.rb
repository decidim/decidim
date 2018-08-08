# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to amendable resources.
  module Amendable
    extend ActiveSupport::Concern

    included do
      has_many :amendments, as: :amendable, foreign_key: "decidim_amendable_id", foreign_type: "decidim_amendable_type", class_name: "Decidim::Amendment"

      # resource.emendations : resources that have amend the resource
      has_many :emendations, through: :amendments, source: :emendation, source_type: name, inverse_of: :emendations

      # resource.amenders :  users that have emendations for the resource
      has_many :amenders, through: :amendments, source: :amender

      # resource.amended : the original resource that was amended
      has_one :amended, as: :amendable, foreign_key: "decidim_emendation_id", foreign_type: "decidim_emendation_type", class_name: "Decidim::Amendment"
      has_one :amendable, through: :amended, source: :amendable, source_type: name
    end

    def amendment
      return Decidim::Amendment.find_by(emendation: id) if emendation?
      Decidim::Amendment.find_by(amendable: id)
    end

    def emendation?
      true if amendable.present?
    end

    def amendable?
      return false if emendation?
      component.settings.amendments_enabled
    end

    def emendation_state
      # return "widthdrawn" if withdrawn? # todo
      amendment.state if emendation?
    end

    def state
      emendation_state
    end
  end
end
