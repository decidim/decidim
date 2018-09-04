# frozen_string_literal: true

require "spec_helper"

describe "Menu", type: :system do
  let(:organization) { create(:organization) }
  let!(:navbar_link) { create(:navbar_link, organization: organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  it "renders the the navbar link in menu main menu" do
    within ".main-nav" do
      expect(page).to have_link(navbar_link.title, href: navbar_link.link)
    end
  end
end
