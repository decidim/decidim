# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe OpenedSurveyEvent do
      include Decidim::ComponentPathHelper

      include_context "when a simple event"

      let(:event_name) { "decidim.events.surveys.survey_opened" }
      let(:resource) { create(:surveys_component) }
      let(:participatory_space) { resource.participatory_space }
      let(:resource_path) { main_component_path(resource) }
      let(:resource_title) { decidim_sanitize_translated(resource.name) }
      let(:email_subject) { "A new survey in #{participatory_space_title}" }
      let(:email_intro) { "The survey #{resource_title} in #{participatory_space_title} is now open. You can participate in it from this page:" }
      let(:email_outro) { "You have received this notification because you are following #{participatory_space_title}. You can stop receiving notifications following the previous link." }
      let(:notification_title) { "The survey <a href=\"#{resource_path}\">#{resource_title}</a> in <a href=\"#{participatory_space_url}\">#{participatory_space_title}</a> is now open." }

      it_behaves_like "a simple event"
      it_behaves_like "a simple event email"
      it_behaves_like "a simple event notification"
    end
  end
end
