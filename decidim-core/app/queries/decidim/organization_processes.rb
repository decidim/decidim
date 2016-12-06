module Decidim
  class OrganizationProcesses < Rectify::Query
    def initialize(organization)
      @organization = organization
    end

    def query
      raise "Organization is mandatory" unless @organization
      ParticipatoryProcess.where(organization: @organization)
    end
  end
end
