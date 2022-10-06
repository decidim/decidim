# frozen_string_literal: true

require "spec_helper"

describe "Admin manages impersonations", type: :system do
  let(:user) { create(:user, :admin, :confirmed, :admin_terms_accepted, organization:) }

  def navigate_to_impersonations_page
    visit decidim_admin.root_path
    click_link "Participants"
    click_link "Impersonations"
  end

  it_behaves_like "manage impersonations examples"
end
