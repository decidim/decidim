# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    describe ProjectsController, type: :controller do
      routes { Decidim::Budgets::Engine.routes }

      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let!(:budget) { create(:budget, component:) }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        sign_in user
      end

      describe "GET index" do
        let(:component) { create(:budgets_component, :with_geocoding_enabled) }

        it "sets two different collections" do
          geocoded_projects = create_list :project, 10, budget: budget, latitude: 1.1, longitude: 2.2
          _non_geocoded_projects = create_list :project, 2, budget: budget, latitude: nil, longitude: nil

          get :index, params: { budget_id: budget.id }
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:index)

          expect(subject.send(:projects).count).to eq 12
          expect(subject.send(:all_geocoded_projects)).to match_array(geocoded_projects)
        end
      end
    end
  end
end
