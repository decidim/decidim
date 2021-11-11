# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserActivitiesController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }

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
    end
  end
end
