# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::IdDocuments::Admin
  describe ConfirmationsController do
    routes { Decidim::Verifications::IdDocuments::AdminEngine.routes }

    let(:organization) { create(:organization, available_authorizations: ["id_documents"]) }
    let(:admin) { create(:user, :admin, :confirmed, organization:) }

    let(:other_organization) { create(:organization, available_authorizations: ["id_documents"]) }
    let(:other_authorization) { create(:authorization, :pending, name: "id_documents", user: create(:user, :confirmed, organization: other_organization)) }

    before do
      request.env["decidim.current_organization"] = organization
      sign_in admin, scope: :user
    end

    describe "GET #new" do
      it "raises not found when pending authorization belongs to another organization" do
        expect do
          get :new, params: { pending_authorization_id: other_authorization.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
