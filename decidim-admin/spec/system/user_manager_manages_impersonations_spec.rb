# frozen_string_literal: true

require "spec_helper"

describe "User manager manages impersonations", type: :system do
  let(:user) { create(:user, :user_manager, :confirmed, organization: organization) }

  def navigate_to_impersonations_page
    visit decidim_admin.root_path
    click_link "Users"
  end

  it_behaves_like "manage impersonations examples"
end
