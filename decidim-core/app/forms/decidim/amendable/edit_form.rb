# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object used to review emendations
    class EditForm < Decidim::Amendable::Form
      mimic :amendment

      attribute :id, Integer
      attribute :user_group_id, Integer
      attribute :emendation_params, Hash

      validates :id, presence: true
      validate :emendation_changes_amendable
      validate :check_amendable_form_validations

      def map_model(model)
        self.emendation_params = model.emendation.attributes.slice(*emendation.amendable_fields.map(&:to_s))
      end
    end
  end
end
