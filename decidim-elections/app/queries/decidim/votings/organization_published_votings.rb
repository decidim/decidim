# frozen_string_literal: true

module Decidim
  module Votings
    # This query class filters published votings given an organization.
    class OrganizationPublishedVotings < Rectify::Query
      def initialize(organization, user = nil)
        @organization = organization
        @user = user
      end

      def query
        Rectify::Query.merge(
          OrganizationVotings.new(@organization),
          VisibleVotings.new(@user),
          PublishedVotings.new
        ).query
      end
    end
  end
end
