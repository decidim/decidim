module Decidim
  module Admin
    class NewsletterForm < Decidim::Form
      include TranslatableAttributes

      translatable_attribute :subject, String
      translatable_attribute :body, String
      validates :subject, :body, translatable_presence: true
    end
  end
end
