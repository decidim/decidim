# frozen_string_literal: true

require "spec_helper"

describe "ExternalDomainWarning", type: :system do
  let(:whitelist) { ["decidim.org", "example.org"] }
  let(:organization) { create(:organization, external_domain_whitelist: whitelist) }
  let(:content) { { en: 'Hello world <a href="http://www.github.com" target="_blank">Very nice link</a><br><a href="http://www.example.org" target="_blank">Another link</a>' } }
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
    expect(page).to have_css("#external-domain-warning")
    expect(page).to have_content("Open external link")
  end

  it "does not show warning on whitelisted links" do
    expect(page).to have_link("Another link", href: "http://www.example.org")
  end

  context "when url has special characters" do
    let(:destination) { "https://example.org/test?foo=bàr" }
    let(:url) { "http://#{organization.host}/link?external_url=#{destination}" }

    it "does not show invalid url alert" do
      visit url
      expect(page).not_to have_content("Invalid URL")
      expect(page).to have_content("b%C3%A0r")
    end
  end

  context "when url is invalid" do
    let(:invalid_url) { "http://#{organization.host}/link?external_url=foo" }

    it "shows invalid url alert" do
      visit invalid_url
      expect(page).to have_content("Invalid URL")
    end
  end

  context "when url has missing protocols" do
    let(:invalid_url) { "http://#{organization.host}/link?external_url=//example.org/some/path" }

    it "shows invalid url alert" do
      visit invalid_url
      expect(page).to have_content("Invalid URL")
    end
  end

  context "when url has a port" do
    let(:destination) { "http://example.org:3000/some/path" }
    let(:invalid_url) { "http://#{organization.host}/link?external_url=#{destination}" }

    it "shows invalid url alert" do
      visit invalid_url
      expect(page).not_to have_content("Invalid URL")
      expect(page).to have_content(destination)
      expect(page).to have_link("Proceed", href: destination)
    end
  end

  context "when url has invalid protocols" do
    let(:invalid_url) { "http://#{organization.host}/link?external_url=javascript://example.org%250aalert(document.location.host)" }

    it "shows invalid url alert" do
      visit invalid_url
      expect(page).to have_content("Invalid URL")
    end
  end

  context "when url is double encoded" do
    let(:invalid_url) { "http://#{organization.host}/link?external_url=http://example.org%250ajavascript:alert(document.location.host)" }

    it "shows invalid url alert" do
      visit invalid_url
      expect(page).to have_content("Invalid URL")
    end
  end

  context "when url is not HTTP" do
    let(:invalid_url) { "http://#{organization.host}/link?external_url=ftp://example.org/some/path" }

    it "shows invalid url alert" do
      visit invalid_url
      expect(page).to have_content("Invalid URL")
    end
  end

  context "when url starts with HTTP but is not valid protocol" do
    let(:invalid_url) { "http://#{organization.host}/link?external_url=httpfoobar://example.org/some/path" }

    it "shows invalid url alert" do
      visit invalid_url
      expect(page).to have_content("Invalid URL")
    end
  end

  context "when url starts with HTTPS but is not valid protocol" do
    let(:invalid_url) { "http://#{organization.host}/link?external_url=httpsfoobar://example.org/some/path" }

    it "shows invalid url alert" do
      visit invalid_url
      expect(page).to have_content("Invalid URL")
    end
  end

  context "when the url is malformed using a simple scenario" do
    let(:invalid_url) { "http://#{organization.host}/link?external_url=javascript:alert(document.location.host)//%0ahttps://www.example.org" }

    it "shows invalid url alert when using simple scenario" do
      visit invalid_url
      expect(page).to have_content("Invalid URL")
      expect(page).to have_current_path(decidim.root_path, ignore_query: true)
    end
  end

  context "when the url is malformed using a complex scenario" do
    let(:invalid_url) do
      %W(
        http://#{organization.host}/link?external_url=javascript:fetch%28%22%2Fprocesses%2Fconsequuntur%2Daperiam%2Ff%2F12%2F
        proposals%2F8%2Fproposal%5Fvote%22%2C%20%7B%22headers%22%3A%7B%22x%2Dcsrf%2Dtoken%22%3Adocument%2EquerySelectorAll%28
        %27%5Bname%3D%22csrf%2Dtoken%22%5D%27%29%5B0%5D%2EgetAttribute%28%22content%22%29%2C%22x%2Drequested%2Dwith%22%3A%20
        %22XMLHttpRequest%22%7D%2C%22method%22%3A%20%22POST%22%2C%22mode%22%3A%20%22cors%22%2C%22credentials%22%3A%20%22
        include%22%7D%29//%0ahttps://www.example.org
      ).join
    end

    it "shows invalid url alert when using complex scenario" do
      visit invalid_url
      expect(page).to have_content("Invalid URL")
      expect(page).to have_current_path(decidim.root_path, ignore_query: true)
    end
  end

  context "without param" do
    let(:invalid_url) { "http://#{organization.host}/link" }

    it "shows invalid url alert" do
      visit invalid_url
      expect(page).to have_content("Invalid URL")
      expect(page).to have_current_path decidim.root_path
    end
  end
end
