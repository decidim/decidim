# frozen_string_literal: true

module Decidim
  module Conferences
    # This query class filters public conferences given an organization in a
    # meaningful prioritized order.
    class OrganizationPrioritizedConferences < Decidim::Query
      def initialize(organization, user = nil)
        @organization = organization
        @user = user
      end

      def query
        Decidim::Query.merge(
          OrganizationPublishedConferences.new(@organization, @user),
          PrioritizedConferences.new
        ).query.with_attached_hero_image
      end
    end
  end
end
