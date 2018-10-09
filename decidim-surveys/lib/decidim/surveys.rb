# frozen_string_literal: true

require "decidim/surveys/admin"
require "decidim/surveys/engine"
require "decidim/surveys/admin_engine"
require "decidim/surveys/component"

module Decidim
  # This namespace holds the logic of the `Surveys` component. This component
  # allows users to create surveys in a participatory process.
  module Surveys
    autoload :SurveyUserAnswersSerializer, "decidim/surveys/survey_user_answers_serializer"
    autoload :DataPortabilitySurveyUserAnswersSerializer, "decidim/surveys/data_portability_survey_user_answers_serializer"
  end
end
