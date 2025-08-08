# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object used to edit emendations
    class EditForm < Decidim::Amendable::Form
      mimic :amendment

      attribute :id, Integer
      attribute :emendation_params, Hash

      validates :id, presence: true
      validate :emendation_must_change_amendable
      validate :amendable_form_must_be_valid

      def map_model(model)
        self.emendation_params = model.emendation.attributes.slice(*amendable_fields_as_string)
      end
    end
  end
end
