# frozen_string_literal: true

require "spec_helper"

describe "Static pages", type: :system do
  let(:organization) { create(:organization) }
  let!(:page1) { create(:static_page, :with_topic, organization: organization) }
  let!(:page2) { create(:static_page, :with_topic, organization: organization) }
  let!(:page3) { create(:static_page, organization: organization) }
  let(:user) { nil }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user if user
  end

  context "with standalone pages" do
    it "lists all the standalone pages" do
      visit decidim.pages_path

      within find(".row", text: "PAGES") do
        expect(page).to have_content translated(page3.title)
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
      let(:user) { create :user, :confirmed, organization: organization }

      it_behaves_like "requesting with very long URL parameters"
    end
  end
end
