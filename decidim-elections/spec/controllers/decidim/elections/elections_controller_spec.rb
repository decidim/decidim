# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe ElectionsController do
      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:component) { create(:elections_component) }

      let(:election_params) do
        {
          component_id: component.id
        }
      end
      let(:params) { { election: election_params } }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
      end

      describe "GET index" do
        it "sorts elections by search defaults" do
          get :index
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:index)
          expect(controller.helpers.paginated_elections.order_values.first).to be_a(Arel::Nodes::Descending)
        end
      end

      describe "GET show" do
        let(:election) { create(:election, :published, component:) }

        it "renders the show template" do
          get :show, params: params.merge(id: election.id)
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:show)
        end

        it "raises a 404 if the election is not found" do
          expect { get :show, params: params.merge(id: "non-existent") }.to raise_error(ActionController::RoutingError)
        end

        it "returns the election as JSON" do
          get :show, params: params.merge(id: election.id, format: :json)
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to include(
            "id" => election.id,
            "title" => translated_attribute(election.title),
            "description" => translated_attribute(election.description),
            "start_date" => nil,
            "end_date" => election.end_at.iso8601,
            "ongoing" => false,
            "status" => "scheduled",
            "questions" => []
          )
        end
      end
    end
  end
end
