# frozen_string_literal: true

require "spec_helper"

describe "Static pages", type: :system do
  let(:organization) { create(:organization) }
  let!(:page1) { create(:static_page, :with_topic, organization:) }
  let!(:page2) { create(:static_page, :with_topic, organization:) }
  let!(:page3) { create(:static_page, organization:) }
  let(:user) { nil }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user if user
  end

  context "with standalone pages" do
    it_behaves_like "accessible page" do
      before { visit decidim.pages_path }
    end

    it "lists all the standalone pages" do
      visit decidim.pages_path

      within find(".row", text: "PAGES") do
        expect(page).to have_content translated(page3.title)
      end
    end

    context "when visiting a single page with topic" do
      it_behaves_like "accessible page" do
        before { visit decidim.page_path(page1) }
      end
    end

    context "when visiting a single page without topic" do
      it_behaves_like "accessible page" do
        before { visit decidim.page_path(page3) }
      end
    end

    context "when page content has embedded iframe" do
      let!(:video_page) { create(:static_page, :with_topic, content:, organization:) }
      let(:content) { { "en" => %(<p>foo</p><p><br></p><iframe class="ql-video" allowfullscreen="true" src="#{iframe_src}" frameborder="0"></iframe><p><br></p><p>bar</p>) } }
      let(:iframe_src) { "http://www.example.org" }

      before do
        stub_request(:get, iframe_src)
          .to_return(status: 200, body: "foo", headers: { "Content-Type" => "text/plain" })
        visit decidim.pages_path
      end

      context "when cookies are rejected" do
        before do
          click_link "Cookie settings"
          click_button "Accept only essential"
        end

        it "disables iframe" do
          visit decidim.page_path(video_page)
          expect(page).to have_content("You need to enable all cookies in order to see this content")
          expect(page).not_to have_selector("iframe")
        end
      end

      context "when cookies are accepted" do
        before do
          click_link "Cookie settings"
          click_button "Accept all"
        end

        it "shows iframe" do
          visit decidim.page_path(video_page)
          expect(page).not_to have_content("You need to enable all cookies in order to see this content")
          expect(page).to have_selector("iframe", count: 1)
        end
      end
    end
  end

  context "with a long list of URL parameters" do
    shared_examples "requesting with very long URL parameters" do
      let(:long_parameters) do
        # This should generate a string of at least 4 KB in length which is
        # the cookie session store's maximum cookie size due to browser
        # limitations. Each parameter here is in the form of "paramxx=aaa",
        # where "paramxx" is the parameter name and "aaa" is the value. The
        # total length of each parameter is therefore 6 + 2 + 100 characters
        # = 108 bytes. Cookie overflow should therefore happen at latest
        # around 38 of these parameters concenated together.
        50.times.map do |i|
          "param#{i.to_s.rjust(2, "0")}=#{SecureRandom.alphanumeric(100)}"
        end.join("&")
      end

      it "responds to requests containing very long URL parameters" do
        # Calling any URL in Decidim with long parameters should not store
        # the parameters in the user_return_to cookie in order to avoid
        # ActionDispatch::Cookies::CookieOverflow exception
        visit "#{decidim.pages_path}?#{long_parameters}"

        expect(page).to have_content(organization.name)
      end
    end

    it_behaves_like "requesting with very long URL parameters"

    context "when authenticated" do
      let(:user) { create :user, :confirmed, organization: }

      it_behaves_like "requesting with very long URL parameters"
    end
  end
end
