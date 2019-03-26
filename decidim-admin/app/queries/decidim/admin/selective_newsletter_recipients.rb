# frozen_string_literal: true

module Decidim
  module Admin
    class SelectiveNewsletterRecipients < Rectify::Query
      def initialize(organization, form)
        @organization = organization
        @form = form
      end

      def query
        Rectify::Query.merge(
          OrganizationNewsletterRecipients.new(@organization),
          SelectiveNewsletterRecipientsForSpace.new(@organization, @form)
        ).query
      end
    end
  end
end
