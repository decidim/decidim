# frozen_string_literal: true

require "spec_helper"

describe "Admin manages managed users", type: :feature do
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  def navigate_to_managed_users_page
    visit decidim_admin.root_path
    click_link "Users"
    click_link "Managed users"
  end

  it_behaves_like "manage managed users examples"
end
