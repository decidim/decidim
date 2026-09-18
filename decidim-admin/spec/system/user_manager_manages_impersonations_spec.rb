# frozen_string_literal: true

require "spec_helper"

describe "User manager manages impersonations" do
  let(:user) { create(:user, :user_manager, :confirmed, :admin_terms_accepted, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  def navigate_to_impersonations_page
    visit decidim_admin.root_path
    click_on "Participants"
  end

  it_behaves_like "manage impersonations examples"
end
