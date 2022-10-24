# frozen_string_literal: true

require "spec_helper"

describe "ExternalDomainWarning", type: :system do
  let(:whitelist) { ["decidim.org", "example.org"] }
  let(:organization) { create(:organization, external_domain_whitelist: whitelist) }
  let(:content) { { en: 'Hello world <a href="http://www.github.com">Very nice link</a><br><a href="http://www.example.org">Another link</a>' } }
  let!(:static_page) { create(:static_page, organization:, show_in_footer: true, allow_public_access: true, content:) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
    click_link static_page.title["en"]
  end

  after do
    expect_no_js_errors
  end

  it "reveals warning when clicking link with an external href" do
    click_link "Very nice link"
    expect(page).to have_css(".reveal-overlay")
    expect(page).to have_content("Open external link")
  end

  it "doesnt show warning on whitelisted links" do
    expect(page).to have_link("Another link", href: "http://www.example.org")
  end

  context "when url is invalid" do
    let(:invalid_url) { "http://#{organization.host}/link?external_url=foo" }

    it "shows invalid url alert" do
      visit invalid_url
      expect(page).to have_content("Invalid URL")
    end
  end

  context "without param" do
    let(:no_param) { "http://#{organization.host}/link" }

    it "shows invalid url alert" do
      visit no_param
      expect(page).to have_content("Invalid URL")
      expect(page).to have_current_path decidim.root_path
    end
  end
end
