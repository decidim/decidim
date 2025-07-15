# frozen_string_literal: true

module Decidim
  module Api
    class ResourceTypeEnum < Decidim::Api::Types::BaseEnum
      description "Resource enum"

      value :budget, "Budget resource"
      value :project, "Project resource"
      value :proposal, "proposal resource"
    end
  end
end
