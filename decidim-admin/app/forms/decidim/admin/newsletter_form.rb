# frozen_string_literal: true

module Decidim
  module Admin
    # The form that validates the data to construct a valid Newsletter.
    class NewsletterForm < Decidim::Form
      mimic :newsletter

      include TranslatableAttributes

      translatable_attribute :subject, String
      translatable_attribute :body, String
      translatable_attribute :cta_text, String
      attribute :cta_url, String
      attribute :cta_enabled, Boolean

      validates :subject, :body, translatable_presence: true

      validates :cta_text, translatable_presence: true, if: :cta_enabled
      validates :cta_url, presence: true, if: :cta_enabled
    end
  end
end
