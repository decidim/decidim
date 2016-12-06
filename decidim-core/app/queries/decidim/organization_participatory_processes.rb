# frozen_string_literal: true
module Decidim
  # This class returns all the visible Participao
  class OrganizationParticipatoryProcesses < Rectify::Query
    def initialize(organization)
      @organization = organization
    end

    def query
      raise MandatoryOrganization unless @organization
      ParticipatoryProcess.where(organization: @organization).published
    end

    class MandatoryOrganization < StandardError; end
  end
end
