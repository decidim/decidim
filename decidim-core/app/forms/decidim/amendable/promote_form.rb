# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object used to promote emendations
    class PromoteForm < Decidim::Amendable::Form
      mimic :amendment

      attribute :id, Integer
      attribute :emendation_params, Hash

      validates :id, presence: true

      def map_model(model)
        self.emendation_params = model.emendation.attributes.slice(*amendable_fields_as_string)
      end
    end
  end
end
