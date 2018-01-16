# frozen_string_literal: true

require "spec_helper"

describe "Admin manages debates", type: :feature do
  let(:manifest_name) { "debates" }

  include_context "when managing a feature as an admin"
  it_behaves_like "manage debates"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_feature_admin
  end
end
