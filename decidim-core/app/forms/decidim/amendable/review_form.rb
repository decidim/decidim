# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object used to review emendations
    class ReviewForm < Decidim::Amendable::Form
      mimic :amend

      attribute :id, String
      attribute :title, String
      attribute :body, String
      attribute :emendation_fields, Object

      validates :id, presence: true
      validates :title, :body, presence: true, etiquette: true
      validates :title, length: { maximum: 150 }

      def title
        @title ||= emendation_fields[:title]
      end

      def body
        @body ||= emendation_fields[:body]
      end

      def emendation_type
        emendation.resource_manifest.model_class_name
      end

      def emendation_fields
        @emendation_fields ||= emendation.form.from_model(emendation)
      end
    end
  end
end
