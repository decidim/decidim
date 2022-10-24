# frozen_string_literal: true

require "spec_helper"

describe "Admin checks active users panel statistics", type: :system do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.root_path
  end

  it "show users Activity panel" do
    expect(page).to have_content(t("decidim.admin.titles.statistics"))
    expect(page).to have_content(t("decidim.admin.users_statistics.users_count.participants"))
    expect(page).to have_content(t("decidim.admin.users_statistics.users_count.admins"))
  end
end
