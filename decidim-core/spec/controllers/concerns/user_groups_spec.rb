# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe "UserGroups" do
    let!(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, organization:) }

    controller do
      include Decidim::NeedsOrganization
      include Decidim::NeedsPermission
      include Decidim::UserGroups

      before_action :enforce_user_groups_enabled

      def show
        render plain: "Hello World"
      end

      private

      def user_has_no_permission_path
        "/"
      end
    end

    before do
      request.env["decidim.current_organization"] = organization
      routes.draw { get "show" => "anonymous#show" }
    end

    it "renders the view" do
      get :show
      expect(response.body).to eq("Hello World")
    end

    context "when groups are disabled for the organization" do
      let!(:organization) { create(:organization, user_groups_enabled: false) }

      it "raises Decidim::ActionForbidden" do
        get :show
        expect(response).to have_http_status(:redirect)
        expect(subject).to redirect_to("/")
      end
    end
  end
end
