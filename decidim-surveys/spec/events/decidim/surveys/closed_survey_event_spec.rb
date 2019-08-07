# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe ClosedSurveyEvent do
      include Decidim::ComponentPathHelper

      include_context "when a simple event"

      let(:event_name) { "decidim.events.surveys.survey_closed" }
      let(:resource) { create(:surveys_component) }
      let(:participatory_space) { resource.participatory_space }
      let(:resource_path) { main_component_path(resource) }

      it_behaves_like "a simple event"

      describe "email_subject" do
        it "is generated correctly" do
          expect(subject.email_subject).to eq("A survey has finished in #{participatory_space_title}")
        end
      end

      describe "email_intro" do
        it "is generated correctly" do
          expect(subject.email_intro)
            .to eq("The survey #{resource.name["en"]} in #{participatory_space_title} has been closed.")
        end
      end

      describe "email_outro" do
        it "is generated correctly" do
          expect(subject.email_outro)
            .to include("You have received this notification because you are following #{participatory_space_title}")
        end
      end

      describe "notification_title" do
        it "is generated correctly" do
          expect(subject.notification_title)
            .to start_with("The survey <a href=\"#{resource_path}\">#{resource.name["en"]}</a> in")
          expect(subject.notification_title)
            .to end_with("<a href=\"#{participatory_space_url}\">#{participatory_space_title}</a> has finished.")
        end
      end
    end
  end
end
