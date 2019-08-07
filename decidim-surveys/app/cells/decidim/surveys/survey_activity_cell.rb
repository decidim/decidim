# frozen_string_literal: true

module Decidim
  module Surveys
    # A cell to display when a Survey has been published.
    class SurveyActivityCell < ActivityCell
      include Decidim::ComponentPathHelper

      def title
        I18n.t(
          "decidim.surveys.last_activity.new_survey_at_html",
          link: participatory_space_link
        )
      end

      def activity_link_path
        main_component_path(component)
      end
    end
  end
end
