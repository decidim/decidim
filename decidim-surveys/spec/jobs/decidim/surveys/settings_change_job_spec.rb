# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe SettingsChangeJob do
      subject { described_class }

      let(:survey) { create(:survey) }
      let(:component) { survey.component }
      let(:previous_settings) do
        { allow_responses: previously_allowing_responses }
      end
      let(:current_settings) do
        { allow_responses: currently_allowing_responses }
      end
      let(:user) { create(:user, organization: component.organization) }
      let!(:follow) { create(:follow, followable: component.participatory_space, user:) }

      context "when there are relevant setting changes" do
        context "when the survey becomes open" do
          let(:previously_allowing_responses) { false }
          let(:currently_allowing_responses) { true }

          it "notifies the space followers about it" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.surveys.survey_opened",
                event_class: Decidim::Surveys::OpenedSurveyEvent,
                resource: component,
                followers: [user]
              )

            subject.perform_now(component.id, previous_settings, current_settings)
          end
        end

        context "when the survey becomes closed" do
          let(:previously_allowing_responses) { true }
          let(:currently_allowing_responses) { false }

          it "notifies the space followers about it" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.surveys.survey_closed",
                event_class: Decidim::Surveys::ClosedSurveyEvent,
                resource: component,
                followers: [user]
              )

            subject.perform_now(component.id, previous_settings, current_settings)
          end
        end
      end

      context "when there are not relevant changes" do
        let(:previously_allowing_responses) { true }
        let(:currently_allowing_responses) { true }

        it "does not notify the upcoming meeting" do
          expect(Decidim::EventsManager)
            .not_to receive(:publish)

          subject.perform_now(component.id, previous_settings, current_settings)
        end
      end
    end
  end
end
