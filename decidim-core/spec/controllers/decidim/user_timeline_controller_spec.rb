# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserTimelineController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, nickname: "Nick", organization: organization) }

    before do
      request.env["decidim.current_organization"] = organization
      sign_in user
    end

    describe "#index" do
      context "with a different user than me" do
        it "raises an ActionController::RoutingError" do
          expect do
            get :index, params: { nickname: "foobar" }
          end.to raise_error(ActionController::RoutingError, "Not Found")
        end
      end

      context "with my user with uppercase" do
        it "returns the lowercased user" do
          get :index, params: { nickname: "NICK" }
          expect(response).to render_template(:index)
        end
      end
    end
  end
end
