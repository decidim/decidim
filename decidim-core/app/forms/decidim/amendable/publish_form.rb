# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object used to publish emendations
    class PublishForm < Decidim::Amendable::Form
      mimic :amendment

      attribute :id, Integer
      attribute :amendable_params, Hash
      attribute :emendation_params, Hash

      validates :id, presence: true

      def map_model(model)
        self.amendable_params = model.amendable.attributes.slice(*amendable_fields_as_string)
        self.emendation_params = model.emendation.attributes.slice(*amendable_fields_as_string)
      end
    end
  end
end
