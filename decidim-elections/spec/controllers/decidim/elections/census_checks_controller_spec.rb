# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    describe CensusChecksController do
      let(:component) { create(:elections_component) }
      let(:organization) { component.organization }
      let(:election) { create(:election, :published, :scheduled, :with_token_csv_census, component:, allow_census_check_before_start: true) }
      let(:params) { { component_id: component.id, election_id: election.id } }
      let(:main_proxy) { Decidim::EngineRouter.main_proxy(component) }
      let(:new_census_check_path) { main_proxy.new_election_census_check_path(election) }
      let(:census_check_path) { main_proxy.election_census_check_path(election) }
      let(:election_path) { main_proxy.election_path(election) }
      let(:voter_data) { election.voters.first.data }

      before do
        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        allow(controller).to receive(:current_participatory_space).and_return(component.participatory_space)
        allow(controller).to receive(:current_component).and_return(component)
        allow(controller).to receive(:election_census_check_path).and_return(census_check_path)
        allow(controller).to receive(:new_election_census_check_path).and_return(new_census_check_path)
        allow(controller).to receive(:election_path).and_return(election_path)
      end

      describe "GET new" do
        it "renders the census check form" do
          get :new, params: params

          expect(response).to have_http_status(:ok)
          expect(assigns(:form)).to be_present
        end

        context "when already authenticated" do
          before do
            session[:session_attributes] = voter_data.slice("email", "token")
          end

          it "redirects to the success page" do
            get :new, params: params

            expect(response).to redirect_to(census_check_path)
          end
        end
      end

      describe "POST create" do
        it "stores the session attributes and redirects to the success page" do
          post :create, params: params.merge(token_csv: voter_data.slice("email", "token"))

          expect(session[:session_attributes]).to include(voter_data.slice("email", "token").stringify_keys)
          expect(response).to redirect_to(census_check_path)
        end

        it "displays the form when the data is invalid" do
          post :create, params: params.merge(token_csv: { email: "wrong@example.com", token: "invalid" })

          expect(session[:session_attributes]).to be_blank
          expect(response).to redirect_to(new_census_check_path)
          expect(flash[:alert]).to eq(I18n.t("decidim.elections.censuses.token_csv_form.invalid"))
        end
      end

      describe "GET show" do
        it "redirects to the form when the session is not authenticated" do
          get :show, params: params

          expect(response).to redirect_to(new_census_check_path)
          expect(flash[:alert]).to eq(I18n.t("decidim.elections.votes.check_census.failed"))
        end

        context "when the session is authenticated" do
          before do
            session[:session_attributes] = voter_data.slice("email", "token")
          end

          it "renders the success page" do
            get :show, params: params

            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:show)
          end
        end
      end
    end
  end
end
