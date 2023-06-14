# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ProfilesController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, nickname: "Nick", organization:) }

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
      context "with a user" do
        context "when confirmed" do
          it "redirects to the correct page" do
            get :show, params: { nickname: "Nick" }
            expect(response).to redirect_to("/profiles/Nick/activity")
          end
        end

        context "when TOS has not been accepted" do
          let!(:user) { create(:user, :confirmed, nickname: "Nick", accepted_tos_version: nil, organization:) }

          it "does not return the page" do
            expect { get :show, params: { nickname: "Nick" } }.to raise_error(ActionController::RoutingError)
          end
        end

        context "when unconfirmed" do
          let!(:user) { create(:user, nickname: "Nick", organization:) }

          it "does not return the page" do
            expect { get :show, params: { nickname: "Nick" } }.to raise_error(ActionController::RoutingError)
          end
        end

        context "when blocked" do
          let!(:user) { create(:user, :confirmed, :blocked, nickname: "Nick", organization:) }

          it "does not return the page" do
            expect { get :show, params: { nickname: "Nick" } }.to raise_error(ActionController::RoutingError)
          end
        end
      end

      context "with a user group" do
        context "when verified and confirmed" do
          let!(:user) { create(:user_group, :confirmed, :verified, nickname: "acme", organization:) }

          it "redirects to the correct page" do
            get :show, params: { nickname: "acme" }

            expect(response).to redirect_to("/profiles/acme/members")
          end
        end

        context "when unconfirmed" do
          let!(:user) { create(:user_group, nickname: "acme", organization:) }

          it "redirects to the correct page" do
            expect { get :show, params: { nickname: "acme" } }.to raise_error(ActionController::RoutingError)
          end
        end

        context "when confirmed but unverified" do
          let!(:user) { create(:user_group, :confirmed, nickname: "acme", organization:) }

          it "redirects to the correct page" do
            expect { get :show, params: { nickname: "acme" } }.to raise_error(ActionController::RoutingError)
          end
        end

        context "when confirmed and verified but blocked" do
          let!(:user) { create(:user_group, :confirmed, :verified, :blocked, nickname: "acme", organization:) }

          it "does not return the page" do
            expect { get :show, params: { nickname: "acme" } }.to raise_error(ActionController::RoutingError)
          end
        end
      end
    end
  end
end
