# frozen_string_literal: true

module Decidim
  module Conferences
    # This query class filters public conferences given an organization in a
    # meaningful prioritized order.
    class OrganizationPrioritizedConferences < Rectify::Query
      def initialize(organization, user = nil)
        @organization = organization
        @user = user
      end

      def query
        Rectify::Query.merge(
          OrganizationPublishedConferences.new(@organization, @user),
          PrioritizedConferences.new
        ).query
      end
    end
  end
end
