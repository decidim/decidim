# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AuthorizationsController, type: :controller do
    include_context "authenticated user"

    describe "handler" do
      it "injects the current_user" do
        controller.params[:handler] = "decidim/dummy_authorization_handler"
        expect(controller.handler.user).to eq(user)
      end
    end

    describe "POST create" do
      context "when the handler is not valid" do
        it "redirects the user" do
          post :create, params: { handler: "foo" }
          expect(response).to redirect_to(account_path)
        end
      end
    end

    describe "GET new" do
      context "when the handler is not valid" do
        it "redirects the user" do
          get :new, params: { handler: "foo" }
          expect(response).to redirect_to(account_path)
        end
      end
    end
  end
end
