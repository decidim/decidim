# frozen_string_literal: true

module Decidim
  module Admin
    # The form that validates the data to construct a valid Newsletter.
    class NewsletterForm < ContentBlockForm
      mimic :newsletter

      include TranslatableAttributes

      translatable_attribute :subject, String
      validates :subject, translatable_presence: true

      def map_model(content_block)
        super(content_block)
        self.subject = newsletter_for(content_block).try(:subject)
      end

      private

      def newsletter_for(content_block)
        Decidim::Newsletter
          .where(organization: content_block.organization)
          .find_by(id: content_block.scoped_resource_id)
      end
    end
  end
end
