# frozen_string_literal: true

module Decidim
  module Admin
    class OrganizationNewsletterRecipients < Rectify::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        Decidim::User.where(organization: @organization)
                            .where.not(newsletter_notifications_at: nil, email: nil, confirmed_at: nil)
                            .not_deleted
      end
    end
  end
end
