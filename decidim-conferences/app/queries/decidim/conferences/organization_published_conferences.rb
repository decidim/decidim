# frozen_string_literal: true

module Decidim
  module Conferences
    # This query class filters published conferences given an organization.
    class OrganizationPublishedConferences < Rectify::Query
      def initialize(organization, user = nil)
        @organization = organization
        @user = user
      end

      def query
        Rectify::Query.merge(
          OrganizationConferences.new(@organization),
          VisibleConferences.new(@user),
          PublishedConferences.new
        ).query
      end
    end
  end
end
