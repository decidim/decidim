# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe "NeedsPermission" do
    let!(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, organization:) }
    let!(:another_user) { create(:user, :confirmed, organization:) }

    controller do
      include Decidim::NeedsPermission

      register_permissions(
        "test",
        ::Decidim::Permissions
      )

      def show
        enforce_permission_to :update, :user, current_user: request.env["decidim.test_user"]

        render plain: "Hello World"
      end

      def token
        render plain: store_share_token.to_s
      end

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for("test")
      end

      def permission_scope
        :public
      end

      def user_has_no_permission_path
        "/you-need-permissions"
      end
    end

    before do
      routes.draw { get "show" => "anonymous#show" }

      request.env["decidim.current_organization"] = organization
      request.env["decidim.test_user"] = another_user
      sign_in user if user
    end

    it "redirects the user to the user_has_no_permissions_path" do
      get :show

      expect(response).to redirect_to("/you-need-permissions")
    end

    context "when the request has a referer defined" do
      let(:referer) { "http://test.host/referer-path" }

      before do
        request.env["HTTP_REFERER"] = referer
      end

      it "redirects the user to the referer URL" do
        get :show

        expect(response).to redirect_to(referer)
      end

      context "with referer pointing to the current path" do
        let(:referer) { "http://test.host/show" }

        it "redirects the user to the user_has_no_permission_path" do
          get :show

          expect(response).to redirect_to("/you-need-permissions")
        end
      end

      context "and the user is not signed in" do
        let(:user) { nil }

        it "redirects the user to the user_has_no_permissions_path" do
          get :show

          expect(response).to redirect_to("/you-need-permissions")
        end
      end
    end

    describe "#store_share_token" do
      before do
        routes.draw { get "token" => "anonymous#token" }
      end

      it "stores a string share_token param in the session" do
        get :token, params: { share_token: "Faketoken" }

        expect(session[:share_token]).to eq("Faketoken")
        expect(response.body).to eq("Faketoken")
      end

      it "does not store an array share_token param in the session" do
        get :token, params: { share_token: %w(a b) }

        expect(session).not_to have_key(:share_token)
        expect(response.body).to be_empty
      end

      it "does not store a hash share_token param in the session" do
        get :token, params: { share_token: { "foo" => "bar" } }

        expect(session).not_to have_key(:share_token)
        expect(response.body).to be_empty
      end

      context "when a token is already stored in the session" do
        before do
          session[:share_token] = "StoredToken"
        end

        it "keeps the stored token when the param is missing" do
          get :token

          expect(session[:share_token]).to eq("StoredToken")
          expect(response.body).to eq("StoredToken")
        end

        it "keeps the stored token when the param is an array" do
          get :token, params: { share_token: %w(a b) }

          expect(session[:share_token]).to eq("StoredToken")
          expect(response.body).to eq("StoredToken")
        end

        it "keeps the stored token when the param is a hash" do
          get :token, params: { share_token: { "foo" => "bar" } }

          expect(session[:share_token]).to eq("StoredToken")
          expect(response.body).to eq("StoredToken")
        end

        it "replaces the stored token when the param is a string" do
          get :token, params: { share_token: "NewToken" }

          expect(session[:share_token]).to eq("NewToken")
          expect(response.body).to eq("NewToken")
        end
      end
    end
  end
end
