# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::AuthorizationCreateModalsController do
  routes { Decidim::Initiatives::Engine.routes }

  let(:organization) { create(:organization, available_authorizations: %w(dummy_authorization_handler)) }
  let(:user) { create(:user, :confirmed, organization:) }
  let!(:initiative_type) { create(:initiatives_type, organization:) }
  let!(:initiative_type_scope) { create(:initiatives_type_scope, type: initiative_type) }

  before do
    request.env["decidim.current_organization"] = organization
    sign_in user, scope: :user
  end

  describe "GET show" do
    it "authorizes the action with the read authorization permission" do
      expect(controller).to receive(:enforce_permission_to)
        .with(:read, :authorization)
        .and_call_original

      get :show, params: { locale: I18n.locale, slug: initiative_type.id }

      expect(response).to have_http_status(:ok)
    end
  end
end
