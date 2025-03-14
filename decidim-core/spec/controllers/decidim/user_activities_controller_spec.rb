# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserActivitiesController do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let!(:user) { create(:user, nickname: "nick", organization:) }

    before do
      request.env["decidim.current_organization"] = organization
    end

    describe "#show" do
      context "with an unknown user" do
        it "raises an ActionController::RoutingError" do
          expect do
            get :index, params: { nickname: "foobar" }
          end.to raise_error(ActionController::RoutingError, "Missing user: foobar")
        end
      end

      context "with an user with uppercase" do
        it "returns the lowercased user" do
          get :index, params: { nickname: "NICK" }
          expect(response).to render_template(:index)
        end
      end
    end
  end
end
