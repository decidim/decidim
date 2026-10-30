# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe SurveysController do
      let(:component) { create(:surveys_component) }
      let(:params) { { component_id: component.id } }
      let(:survey_path) { Decidim::EngineRouter.main_proxy(component).survey_path(survey) }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
      end

      describe "GET index" do
        context "when there is a single open published survey" do
          let!(:survey) { create(:survey, :published, :allow_responses, component:) }

          it "redirects to the survey" do
            get(:index, params:)

            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(survey_path)
          end

          it "does not redirect for JS requests" do
            request.headers["X-Requested-With"] = "XMLHttpRequest"

            get :index, params: params.merge(format: :js)

            expect(response).to have_http_status(:ok)
          end
        end

        context "when the single published survey is closed" do
          let!(:survey) { create(:survey, :published, component:) }

          it "redirects to the survey" do
            get(:index, params:)

            expect(response).to redirect_to(survey_path)
          end
        end

        context "when there is more than one published survey" do
          let!(:survey) { create(:survey, :published, component:) }
          let!(:another_survey) { create(:survey, :published, component:) }

          it "renders the index template" do
            get(:index, params:)

            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:index)
          end
        end

        context "when there are no published surveys" do
          let!(:survey) { create(:survey, component:) }

          it "renders the index template" do
            get(:index, params:)

            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:index)
          end
        end

        context "when there is a single published survey and another unpublished one" do
          let!(:survey) { create(:survey, :published, component:) }
          let!(:unpublished_survey) { create(:survey, component:) }

          it "redirects to the published survey" do
            get(:index, params:)

            expect(response).to redirect_to(survey_path)
          end
        end
      end
    end
  end
end
