# frozen_string_literal: true

module Decidim
  module Admin
    # The form that validates the data to construct a valid Newsletter.
    class NewsletterForm < Decidim::Form
      mimic :newsletter

      include TranslatableAttributes

      translatable_attribute :subject, String
      translatable_attribute :body, String
      validates :subject, :body, translatable_presence: true
    end
  end
end
