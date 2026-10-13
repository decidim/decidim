# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::CreateInitiativeController do
  routes { Decidim::Initiatives::Engine.routes }

  let(:organization) { create(:organization, available_authorizations: %w(dummy_authorization_handler)) }
  let(:user) { create(:user, :confirmed, organization:) }
  let!(:initiative_type) { create(:initiatives_type, organization:) }
  let!(:initiative_type_scope) { create(:initiatives_type_scope, type: initiative_type) }
  let!(:other_initiative_type) { create(:initiatives_type, organization:) }
  let!(:other_initiative_type_scope) { create(:initiatives_type_scope, type: other_initiative_type) }

  before do
    request.env["decidim.current_organization"] = organization
    allow(Decidim::Initiatives).to receive(:creation_enabled).and_return(true)
    allow(Decidim::Initiatives).to receive(:do_not_require_authorization).and_return(true)
    sign_in user, scope: :user
  end

  describe "GET load_initiative_draft" do
    let!(:initiative) { create(:initiative, :created, author: user, organization:) }

    it "authorizes the action with the create initiative permission" do
      expect(controller).to receive(:enforce_permission_to)
        .with(:create, :initiative, { initiative_type: nil })
        .and_call_original

      get :load_initiative_draft, params: { locale: I18n.locale, initiative_id: initiative.id }

      expect(response).to be_redirect
    end
  end

  describe "GET select_initiative_type" do
    it "authorizes the action with the create initiative permission" do
      expect(controller).to receive(:enforce_permission_to)
        .with(:create, :initiative, { initiative_type: nil })
        .and_call_original

      get :select_initiative_type, params: { locale: I18n.locale }

      expect(response).to have_http_status(:ok)
    end
  end

  describe "PUT store_initiative_type" do
    it "authorizes the action with the create initiative permission" do
      expect(controller).to receive(:enforce_permission_to)
        .with(:create, :initiative, { initiative_type: })
        .and_call_original

      put :store_initiative_type, params: { locale: I18n.locale, initiative: { type_id: initiative_type.id } }

      expect(response).to be_redirect
    end
  end
end
