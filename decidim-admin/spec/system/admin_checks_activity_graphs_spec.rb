# frozen_string_literal: true

require "spec_helper"

describe "Admin checks activity graphs", type: :system do
  let(:organization) { create(:organization) }

  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.root_path
  end

  it "lists activity graphs" do
    expect(page).to have_content("ACTIVITY GRAPHS")
  end
end
