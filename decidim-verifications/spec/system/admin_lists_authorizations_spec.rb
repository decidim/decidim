# frozen_string_literal: true

require "spec_helper"

describe "Admin lists authorizations", type: :system do
  let!(:organization) do
    create(:organization, available_authorizations: ["id_documents"])
  end

  let(:admin) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_link "Participants"
    within_admin_sidebar_menu do
      click_link "Authorizations"
    end
  end

  it "allows the user to list all available authorization methods" do
    within "[data-content]" do
      expect(page).to have_content("Identity documents")
    end
  end
end
