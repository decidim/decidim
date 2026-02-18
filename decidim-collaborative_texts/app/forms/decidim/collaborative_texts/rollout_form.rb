# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class RolloutForm < Decidim::Form
      attribute :body, Decidim::Attributes::RichText
      attribute :draft, Boolean, default: true
      attribute :accepted, Array[Integer], default: []
      attribute :pending, Array[Integer], default: []

      validates :body, presence: true

      def document
        @document ||= context[:document]
      end

      def accepted_suggestions
        @accepted_suggestions ||= document.suggestions.where(id: accepted)
      end

      def pending_suggestions
        @pending_suggestions ||= document.suggestions.where(id: pending)
      end
    end
  end
end
