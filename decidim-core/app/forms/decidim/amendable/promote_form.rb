# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object used to promote emendations
    class PromoteForm < Decidim::Amendable::Form
      mimic :amend

      attribute :id, String

      validates :id, presence: true

      def emendation
        @emendation ||= Amendment.find_by(decidim_emendation_id: id).emendation
      end

      def amendable_type
        emendation_type
      end

      def emendation_type
        emendation.resource_manifest.model_class_name
      end
    end
  end
end
