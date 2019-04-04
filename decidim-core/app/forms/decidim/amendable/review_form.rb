# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object used to review emendations
    class ReviewForm < Decidim::Amendable::Form
      mimic :amendment

      attribute :id, String
      attribute :emendation_params, Object

      validates :emendation_params, presence: true
      validate :check_amendable_form_validations
    end
  end
end
