# frozen_string_literal: true

require "spec_helper"

describe "Social share button" do
  let!(:organization) { create(:organization) }
  let!(:resource) { create(:dummy_resource) }
  let(:resource_path) { Decidim::ResourceLocatorPresenter.new(resource).path }

  let(:short_link) do
    create(
      :short_link,
      target: resource,
      mounted_engine_name: engine_name,
      route_name:
    )
  end
  let(:engine_name) { "decidim_participatory_process_dummy" }
  let(:route_name) { "dummy_resource" }

  before { switch_to_host(resource.organization.host) }

  shared_examples_for "showing the social share buttons" do
    it "shows the 'socialShare' modal" do
      within "#socialShare", visible: :visible do
        expect(page).to have_css("h2", text: "Share")
        expect(page).to have_css("[data-social-share]")
      end
    end

    it "shows the 'Share to X' button" do
      within "[data-social-share]" do
        expect(page).to have_css('a[data-site="x"]')
      end
    end

    it "shows the 'Share to Facebook' button" do
      within "[data-social-share]" do
        expect(page).to have_css('a[data-site="facebook"]')
      end
    end

    it "shows the 'Share to Telegram' button" do
      within "[data-social-share]" do
        expect(page).to have_css('a[data-site="telegram"]')
      end
    end

    it "shows the 'Share to Whatsapp' button" do
      within "[data-social-share]" do
        expect(page).to have_css('a[data-site="whatsapp"]')
      end
    end

    it "does not have the external domain warning in the URL" do
      within "[data-social-share]" do
        link = find('a[data-site="telegram"]')
        expect(link[:href]).not_to include("/link?external_url")
      end
    end
  end

  context "without cookie dialog" do
    before do
      page.driver.browser.execute_cdp(
        "Network.setCookie",
        domain: resource.organization.host,
        name: Decidim.consent_cookie_name,
        value: { essential: true }.to_json,
        path: "/"
      )
    end

    context "when the user is logged in" do
      before do
        login_as resource.author, scope: :user
        visit resource_path
      end

      context "and clicks on the Share button" do
        before { click_on "Share" }

        it_behaves_like "showing the social share buttons"
      end
    end

    context "when the user is NOT logged in" do
      before { visit resource_path }

      context "and clicks on the Share button" do
        before { click_on "Share" }

        it_behaves_like "showing the social share buttons"
      end
    end
  end

  context "when sharing resource by link" do
    before do
      visit resource_path
      click_on "Share"
    end

    it "short link is displayed on the share modal" do
      within ".share-modal__input" do
        expect(page).to have_css("button[data-clipboard-copy='#urlShareLink']")
        link = find("input#urlShareLink")
        within "#urlShareLink" do
          expect(page).to have_no_content(resource_path)
          expect(link[:value]).to include("#{resource.organization.host}:#{Capybara.current_session.server.port}/s/")
        end
      end
    end

    it "short link redirects to the correct resource path" do
      visit "http://#{resource.organization.host}:#{Capybara.server_port}/s/#{short_link.identifier}"

      expect(page).to have_current_path(resource_path)
    end
  end
end
