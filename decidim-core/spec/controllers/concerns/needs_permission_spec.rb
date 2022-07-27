# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe "NeedsPermission", type: :controller do
    let!(:organization) { create :organization }
    let!(:user) { create :user, :confirmed, organization: }
    let!(:another_user) { create :user, :confirmed, organization: }

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
  end
end
