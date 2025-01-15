# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe SurveyHelper do
      let(:organization) { create(:organization) }
      let(:participatory_space) { create(:participatory_process, organization:) }
      let(:surveys_component) { create(:surveys_component, :published, participatory_space:) }
      let(:survey) { create(:survey, component: surveys_component) }

      describe "#no_permission" do
        it "renders the authorization modal" do
          authorizations = double("authorizations")
          allow(helper).to receive(:authorizations).and_return(authorizations)

          expect(helper).to receive(:cell).with("decidim/authorization_modal", authorizations)
          helper.no_permission
        end
      end

      describe "#resource" do
        it "returns the questionnaire resource" do
          allow(helper).to receive(:questionnaire_for).and_return(survey)
          expect(helper.resource).to eq(survey)
        end
      end

      describe "#current_component" do
        let(:params) { { component_id: surveys_component.id } }

        it "returns the current component based on params" do
          allow(helper).to receive(:params).and_return(params)
          expect(helper.current_component).to eq(surveys_component)
        end
      end

      describe "#authorization_action" do
        let(:params) { { authorization_action: "some_action" } }

        it "returns the authorization action from params" do
          allow(helper).to receive(:params).and_return(params)
          expect(helper.authorization_action).to eq("some_action")
        end
      end

      describe "#authorize_action_path" do
        it "returns the authorization path for a handler" do
          status = double("status", current_path: "/path/to/authorization")
          authorizations = double("authorizations")
          allow(helper).to receive(:authorizations).and_return(authorizations)
          allow(authorizations).to receive(:status_for).with("some_handler").and_return(status)

          expect(helper.authorize_action_path("some_handler")).to eq("/path/to/authorization")
        end
      end

      describe "#filter_date_values" do
        it "returns the correct filter values" do
          expected_values = [:all, :open, :closed]
          allow(helper).to receive(:flat_filter_values).with(:all, :open, :closed, scope: "decidim.surveys.surveys.filters.date_values").and_return(expected_values)

          expect(helper.filter_date_values).to eq(expected_values)
        end
      end
    end
  end
end
