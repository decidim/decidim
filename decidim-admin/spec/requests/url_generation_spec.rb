# frozen_string_literal: true

require "spec_helper"

describe "Admin URL generation with untrusted parameters" do
  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:headers) { { "HOST" => organization.host } }

  before do
    login_as admin, scope: :user
  end

  it "does not use the script_name parameter to generate links" do
    get(
      "/en/admin/users?script_name=javascript:alert(1)//",
      headers:
    )

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to match(/href="\s*javascript:/i)
  end
end
