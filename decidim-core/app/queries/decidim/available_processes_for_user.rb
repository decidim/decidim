# frozen_string_literal: true
module Decidim
  class AvailableProcessesForUser < Rectify::Query
    def initialize(user, organization)
      @user = user
      @organization = organization
    end

    def query
      if user && user.role?(:admin)
        OrganizationProcesses.new(organization).query
      else
        PublishedProcesses.new(organization).query
      end
    end

    private

    attr_reader :user, :organization
  end
end
