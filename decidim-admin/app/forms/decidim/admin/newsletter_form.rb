# frozen_string_literal: true

module Decidim
  module Admin
    # The form that validates the data to construct a valid Newsletter.
    class NewsletterForm < ContentBlockForm
      mimic :newsletter

      include TranslatableAttributes

      translatable_attribute :subject, String
      validates :subject, translatable_presence: true
    end
  end
end
