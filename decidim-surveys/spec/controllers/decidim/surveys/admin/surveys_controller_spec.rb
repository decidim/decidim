# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    module Admin
      describe SurveysController do
        let(:component) { survey.component }
        let(:survey) { create(:survey) }
        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }
        let(:params) do
          {
            component_id: survey.component.id,
            participatory_process_slug: survey.component.participatory_space.slug,
            id: survey.id
          }
        end

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_component"] = component
          sign_in user, scope: :user
        end

        describe "index" do
          it "renders the index template" do
            get(:index, params:)
            expect(response).to render_template(:index)
          end

          it "renders the index template even when no surveys are present" do
            allow(Decidim::Surveys::Survey).to receive(:where).and_return([])
            get(:index, params:)
            expect(response).to render_template(:index)
          end
        end
      end
    end
  end
end
