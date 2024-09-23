# frozen_string_literal: true

module Decidim
  module Surveys
    # A command with all the business logic to create a new survey in the
    # system.
    class CreateSurvey < Decidim::Command::CreateResource
      fetch_form_attributes :title, :description
    end
  end
end
