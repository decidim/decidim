# frozen_string_literal: true

module Decidim
  module Conferences
    # This query class filters published conferences given an organization.
    class OrganizationPublishedConferences < Decidim::Query
      def initialize(organization, user = nil)
        @organization = organization
        @user = user
      end

      def query
        Decidim::Query.merge(
          OrganizationConferences.new(@organization),
          VisibleConferences.new(@user),
          PublishedConferences.new
        ).query.order(start_date: :desc)
      end
    end
  end
end
