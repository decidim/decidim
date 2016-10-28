# frozen_string_literal: true
module Decidim
  class PublishedProcesses < Rectify::Query
    def initialize(organization = nil)
      @organization = organization
    end

    def query
      scope.includes(:active_step).published
    end

    private

    attr_reader :organization

    def scope
      return ParticipatoryProcess.all unless organization

      OrganizationProcesses.new(organization).query
    end
  end
end
