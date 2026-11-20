# frozen_string_literal: true

require "spec_helper"

describe "Free resource authorization modal" do
  let(:organization) { create(:organization) }
  let(:other_organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let!(:other_user) { create(:user, organization: other_organization) }

  before do
    login_as user, scope: :user
  end

  it "returns not found for a resource from another organization" do
    get decidim.free_resource_authorization_modal_path(authorization_action: "foo", resource_name: "user", resource_id: other_user.id),
        headers: { "HOST" => organization.host }

    expect(response).to have_http_status(:not_found)
  end

  it "returns not found for an unknown resource name" do
    get decidim.free_resource_authorization_modal_path(authorization_action: "foo", resource_name: "unknown", resource_id: other_user.id),
        headers: { "HOST" => organization.host }

    expect(response).to have_http_status(:not_found)
  end
end
