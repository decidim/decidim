# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ProfilesController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let!(:user) { create(:user, nickname: "Nick", organization:) }

    before do
      request.env["decidim.current_organization"] = organization
    end

    describe "#badges" do
      context "with an user with uppercase" do
        it "returns the lowercased user" do
          get :badges, params: { nickname: "NICK" }
          expect(response).to render_template(:show)
        end
      end
    end

    describe "#show" do
      context "with a normal user" do
        it "redirects to the correct page" do
          get :show, params: { nickname: "Nick" }
          expect(response).to redirect_to("/profiles/Nick/activity")
        end
      end

      context "with a blocked user" do
        let!(:user) { create(:user, :confirmed, :blocked, nickname: "Nick", organization:) }

        it "does not return the page" do
          expect { get :show, params: { nickname: "Nick" } }.to raise_error(ActionController::RoutingError)
        end
      end

      context "with a normal user group" do
        let!(:user) { create(:user_group, nickname: "acme", organization:) }

        it "redirects to the correct page" do
          get :show, params: { nickname: "acme" }

          expect(response).to redirect_to("/profiles/acme/members")
        end
      end

      context "with a blocked user group" do
        let!(:user) { create(:user_group, nickname: "acme", organization:) }

        it "does not return the page" do
          expect { get :show, params: { nickname: "blocked" } }.to raise_error(ActionController::RoutingError)
        end
      end
    end
  end
end
