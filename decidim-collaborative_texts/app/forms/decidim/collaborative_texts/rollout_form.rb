# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class RolloutForm < Decidim::Form
      attribute :body, Decidim::Attributes::RichText
      attribute :draft, Boolean, default: true
      attribute :accepted, Array[Integer], default: []

      validates :body, presence: true

      def document
        @document ||= context[:document]
      end
    end
  end
end
