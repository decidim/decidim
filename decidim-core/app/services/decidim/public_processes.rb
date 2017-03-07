# frozen_string_literal: true
module Decidim
  # This service is in charge of gathering the ParticipatoryProcess and
  # ParticipatoryProcessGroup that are public and should be displayed together.
  class PublicProcesses
    def initialize(organization)
      @organization = organization
    end

    def collection
      (participatory_processes + participatory_process_groups).flatten
    end

    private

    attr_reader :organization

    def participatory_processes
      Decidim::ParticipatoryProcess.where(organization: organization).published
    end

    def participatory_process_groups
      Decidim::ParticipatoryProcessGroup.where(organization: organization)
    end
  end
end
