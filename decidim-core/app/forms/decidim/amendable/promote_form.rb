# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object used to promote emendations
    class PromoteForm < Decidim::Amendable::Form
      mimic :amendment

      attribute :id, String
      attribute :emendation_params, Object

      validates :id, presence: true

      def emendation_params
        {
          title: emendation&.title,
          body: emendation&.body
        }
      end
    end
  end
end
