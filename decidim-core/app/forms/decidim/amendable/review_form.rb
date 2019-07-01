# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object used to review emendations
    class ReviewForm < Decidim::Amendable::Form
      mimic :amendment

      attribute :id, Integer
      attribute :emendation_params, Hash

      validates :id, presence: true
      validate :check_amendable_form_validations

      def map_model(model)
        self.emendation_params = model.emendation.attributes.slice(*amendable_fields_as_string)
      end
    end
  end
end
