# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserTimelineController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, nickname: "Nick", organization:) }
    let!(:another_user) { create(:user, :confirmed, nickname: "foobar", organization:) }

    before do
      request.env["decidim.current_organization"] = organization
      sign_in user if user
    end

    describe "#index" do
      context "with a different user than me" do
        it "redirects to the public activity" do
          get :index, params: { nickname: "foobar" }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to profile_activity_path(nickname: "foobar")
        end
      end

      context "with my user with uppercase" do
        it "returns the lowercased user" do
          get :index, params: { nickname: "NICK" }
          expect(response).to render_template(:index)
        end
      end

      context "when logged out" do
        let!(:user) { nil }

        it "redirects to login" do
          get :index, params: { nickname: "foobar" }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to new_user_session_path
        end
      end
    end
  end
end
