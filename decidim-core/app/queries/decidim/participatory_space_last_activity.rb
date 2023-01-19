# frozen_string_literal: true

module Decidim
  # This query finds the public ActionLog entries that can be shown in the
  # activities views of the application within a Decidim participatory space.
  class ParticipatorySpaceLastActivity < Decidim::Query
    attr_reader :participatory_space, :organization

    def initialize(participatory_space)
      @participatory_space = participatory_space
      @organization = participatory_space&.organization
    end

    def query
      LastActivity.new(organization).query.where(participatory_space:)
    end
  end
end
