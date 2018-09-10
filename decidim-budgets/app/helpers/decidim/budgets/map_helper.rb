# frozen_string_literal: true
module Decidim
  module Budgets
    # This helper include some methods for rendering projects dynamic maps.
    module MapHelper
      # Serialize a collection of geocoded projects to be used by the dynamic map component
      #
      # geocoded_projects - A collection of geocoded projects
      def projects_data_for_map(geocoded_projects)
        geocoded_projects.map do |project|
          project.slice(:latitude, :longitude, :address)
            .merge(title: translated_attribute(project.title),
                   description: translated_attribute(project.description),
                   icon: icon("proposals", width: 40, height: 70, remove_icon_class: true),
                   link: project_path(project))
        end
      end
    end
  end
end
