# frozen_string_literal: true

require "spec_helper"

describe "User manager manages managed users", type: :feature do
  let(:user) { create(:user, :user_manager, :confirmed, organization: organization) }

  def navigate_to_managed_users_page
    visit decidim_admin.root_path
    click_link "Users"
  end

  it_behaves_like "manage managed users examples"
end
