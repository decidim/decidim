# frozen_string_literal: true
module Decidim
  class OrganizationProcesses < Rectify::Query
    def initialize(organization)
      @organization = organization
    end

    def query
      organization.participatory_processes.includes(:active_step)
    end

    private

    attr_reader :organization
  end
end
