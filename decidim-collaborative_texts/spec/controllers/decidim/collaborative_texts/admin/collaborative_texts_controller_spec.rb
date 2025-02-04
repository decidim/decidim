# frozen_string_literal: true

require "spec_helper"

describe Decidim::CollaborativeTexts::Admin::CollaborativeTextsController do
  routes { Decidim::CollaborativeTexts::AdminEngine.routes }

  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }

  before do
    request.env["decidim.current_organization"] = user.organization
    sign_in user, scope: :user
  end

  describe "GET #index" do
    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end
  end
end
