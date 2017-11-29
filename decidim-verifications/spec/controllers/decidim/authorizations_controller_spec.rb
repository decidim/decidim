# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications
  describe AuthorizationsController, type: :controller do
    routes { Decidim::Verifications::Engine.routes }

    let(:user) { create(:user, :confirmed) }

    before do
      request.env["decidim.current_organization"] = user.organization
      sign_in user, scope: :user
    end

    describe "handler" do
      it "injects the current_user" do
        controller.params[:handler] = "dummy_authorization_handler"
        expect(controller.send(:handler).user).to eq(user)
      end
    end

    describe "POST create" do
      context "when the handler is not valid" do
        it "redirects the user" do
          post :create, params: { handler: "foo" }
          expect(response).to redirect_to(authorizations_path)
        end
      end
    end

    describe "GET new" do
      context "when the handler is not valid" do
        it "redirects the user" do
          get :new, params: { handler: "foo" }
          expect(response).to redirect_to(authorizations_path)
        end
      end
    end
  end
end
