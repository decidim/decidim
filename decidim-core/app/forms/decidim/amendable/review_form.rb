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

      def emendation_author
        return emendation.creator.user_group if emendation.creator.user_group
        emendation.creator_author
      end
    end
  end
end
