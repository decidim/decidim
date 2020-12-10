# frozen_string_literal: true

module Decidim
  module Budgets
    class ProjectSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper

      # Public: Initializes the serializer with a project.
      def initialize(project)
        @project = project
      end
    end
  end
end
