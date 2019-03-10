# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object used to promote emendations
    class PromoteForm < Decidim::Amendable::Form
      mimic :amendment

      attribute :id, String

      validates :id, presence: true

      def emendation
        @emendation ||= Amendment.find_by(decidim_emendation_id: id).emendation
      end
    end
  end
end
