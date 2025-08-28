# frozen_string_literal: true

require "spec_helper"

describe "AdminTosAcceptance" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, admin_terms_accepted_at: nil, organization:) }
  let(:review_message) { "Please take a moment to review the admin terms of service. Otherwise you will not be able to manage the platform" }

  before do
    switch_to_host(organization.host)
  end

  describe "when an admin" do
    before do
      login_as user, scope: :user
    end

    context "when they visit the dashboard" do
      before do
        visit decidim_admin.root_path
      end

      it "has a message that they need to accept the admin TOS" do
        expect(page).to have_content(review_message)
      end

      it "has the main navigation empty" do
        within ".layout-nav" do
          expect(page).to have_no_css("li a")
        end
      end
    end

    context "when they visit other admin pages" do
      before do
        visit decidim_admin.newsletters_path
      end

      it "has a message that they need to accept the admin TOS" do
        expect(page).to have_content(review_message)
      end
    end

    context "when they visit other admin pages from other engines" do
      before do
        visit decidim_admin_participatory_processes.participatory_processes_path
      end

      it "has a message that they need to accept the admin TOS" do
        expect(page).to have_content(review_message)
      end

      it "allows accepting and redirects to the previous page" do
        click_on "I agree with the terms"
        expect(page).to have_content("New process")
        expect(page).to have_content("Process groups")
      end

      context "with a long list of URL parameters" do
        let(:long_parameters) do
          # This should generate a string of at least 4 KB in length which is
          # the cookie session store's maximum cookie size due to browser
          # limitations. Each parameter here is in the form of "paramxx=aaa",
          # where "paramxx" is the parameter name and "aaa" is the value. The
          # total length of each parameter is therefore 6 + 2 + 100 characters
          # = 108 bytes. Cookie overflow should therefore happen at latest
          # around 38 of these parameters concatenated together.
          50.times.map do |i|
            "param#{i.to_s.rjust(2, "0")}=#{SecureRandom.alphanumeric(100)}"
          end.join("&")
        end

        it "responds to requests containing very long URL parameters" do
          # Calling any URL in Decidim with long parameters should not store
          # the parameters in the user_return_to cookie in order to avoid
          # ActionDispatch::Cookies::CookieOverflow exception
          visit "#{decidim_admin_participatory_processes.participatory_processes_path}?#{long_parameters}"
          expect(page).to have_content(review_message)
          click_on "I agree with the terms"
          expect(page).to have_content("New process")
          expect(page).to have_content("Process groups")
        end
      end
    end

    context "when they visit the TOS page" do
      before do
        visit decidim_admin.admin_terms_show_path
      end

      it "renders the TOS page" do
        expect(page).to have_content("Agree to the terms of service")
      end

      it "allows accepting the terms" do
        click_on "I agree with the terms"
        expect(page).to have_content("Statistics")

        within ".layout-nav" do
          expect(page).to have_content("Newsletters")
          expect(page).to have_content("Participants")
          expect(page).to have_content("Settings")
          expect(page).to have_content("Admin activity log")
        end
      end
    end
  end
end
