# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters published processes given an organization.
    class OrganizationPublishedParticipatoryProcesses < Rectify::Query
      def initialize(organization, user = nil)
        @organization = organization
        @user = user
      end

      def query
        Rectify::Query.merge(
          OrganizationParticipatoryProcesses.new(@organization),
          VisibleParticipatoryProcesses.new(@user),
          PublishedParticipatoryProcesses.new
        ).query.order(weight: :asc)
      end
    end
  end
end
