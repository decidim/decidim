# frozen_string_literal: true

require "spec_helper"

describe "ExternalDomainWarning", type: :system do
  let(:whitelist) { ["decidim.org", "example.org"] }
  let(:organization) { create(:organization, external_domain_whitelist: whitelist) }
  let(:content) { { en: 'Hello world <a href="http://www.github.com">Very nice link</a><br><a href="http://www.example.org">Another link</a>' } }
  let!(:static_page) { create(:static_page, organization: organization, show_in_footer: true, allow_public_access: true, content: content) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
    click_link static_page.title["en"]
  end

  it "shows warning when clicking link with an external link" do
    click_link "Very nice link"
    expect(page).to have_content("External link warning")
  end

  it "doesnt show warning on whitelisted links" do
    expect(page).to have_link("Another link", href: "http://www.example.org")
  end
end
