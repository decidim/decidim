# frozen_string_literal: true

require "spec_helper"

describe "Admin manages debates", type: :system do
  let(:manifest_name) { "debates" }

  include_context "when managing a component as an admin"
  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  it_behaves_like "manage debates"
  it_behaves_like "manage announcements"
end
