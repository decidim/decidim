# frozen_string_literal: true
module Decidim
  # This service is in charge of gathering the ParticipatoryProcess and
  # ParticipatoryProcessGroup that are public and should be displayed together.
  class PublicProcesses

    # Initializes the PublicProcesses
    #
    # organization - The current organization
    def initialize(organization)
      @organization = organization
    end

    # Public: The collection of published processes and groups from the given
    # organization to be displayed at processes index.
    #
    # Returns an Array.
    def collection
      (participatory_processes + participatory_process_groups).flatten
    end

    # Public: The collection of published ParticipatoryProcess to be displayed at the
    # process index.
    #
    # Returns an ActiveRecord::Relation.
    def participatory_processes
      @participatory_processes ||= ordered_processes.published
    end

    private

    attr_reader :organization

    def ordered_processes
      @sorted_processes ||= Decidim::ParticipatoryProcess.where(organization: organization).order("promoted DESC").includes(:active_step).order("decidim_participatory_process_steps.end_date ASC")
    end

    def participatory_process_groups
      Decidim::ParticipatoryProcessGroup.where(organization: organization)
    end
  end
end
