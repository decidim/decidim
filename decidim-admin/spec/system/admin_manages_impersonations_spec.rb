# frozen_string_literal: true

require "spec_helper"

describe "Admin manages impersonations", type: :system do
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  def navigate_to_impersonations_page
    visit decidim_admin.root_path
    click_link "Users"
    click_link "Impersonations"
  end

  it_behaves_like "manage impersonations examples"
end
