# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Admin manages initiative type permissions" do
  let(:organization) { create(:organization, available_authorizations: %w(dummy_authorization_handler)) }
  let(:other_organization) { create(:organization, available_authorizations: %w(dummy_authorization_handler)) }

  let!(:initiatives_type) { create(:initiatives_type, organization:) }
  let!(:other_initiatives_type) { create(:initiatives_type, organization: other_organization) }

  let(:permissions) do
    {
      "create" => {
        "authorization_handlers" => {
          "dummy_authorization_handler" => {}
        }
      }
    }
  end

  let(:request_params) { { component_permissions: { permissions: {} } } }

  before do
    initiatives_type.create_resource_permission!(permissions:)
    other_initiatives_type.create_resource_permission!(permissions:)
    host! organization.host
  end

  def request_path(type)
    "/en/admin/initiatives_types/#{type.id}/permissions"
  end

  context "when the user is an organization admin" do
    let(:user) { create(:user, :admin, :confirmed, organization:) }

    before { login_as user, scope: :user }

    it "updates the permissions of an initiative type from the current organization" do
      put request_path(initiatives_type), params: request_params

      expect(response).to have_http_status(:redirect)
      expect(initiatives_type.reload.permissions).to eq({})
    end

    it "does not update an initiative type from another organization" do
      put request_path(other_initiatives_type), params: request_params

      expect(response).to have_http_status(:not_found)
      expect(other_initiatives_type.reload.permissions).to eq(permissions)
    end

    it "does not resolve another resource type from the resource_name parameter" do
      other_component = create(:debates_component, participatory_space: create(:participatory_process, organization: other_organization))
      other_debate = create(:debate, component: other_component)
      other_debate.create_resource_permission!(permissions:)

      put request_path(initiatives_type), params: request_params.merge(resource_name: "debate", debate_id: other_debate.id)

      expect(response).to have_http_status(:redirect)
      expect(other_debate.reload.permissions).to eq(permissions)
      expect(initiatives_type.reload.permissions).to eq({})
    end
  end

  context "when the user has an evaluator role in the organization" do
    let(:user) { create(:user, :admin_terms_accepted, :confirmed, organization:) }

    before do
      process = create(:participatory_process, organization:)
      create(:participatory_process_user_role, user:, participatory_process: process, role: "evaluator")
      login_as user, scope: :user
    end

    it "cannot update the permissions of an initiative type" do
      put request_path(initiatives_type), params: request_params

      expect(response).to have_http_status(:redirect)
      expect(initiatives_type.reload.permissions).to eq(permissions)
    end

    it "cannot access an initiative type from another organization" do
      put request_path(other_initiatives_type), params: request_params

      expect(response).to have_http_status(:not_found)
      expect(other_initiatives_type.reload.permissions).to eq(permissions)
    end
  end
end
