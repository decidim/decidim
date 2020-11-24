# frozen_string_literal: true

require "spec_helper"

describe "UserTosAcceptance", type: :system do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:tos_page) { Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization: organization) }
  let(:btn_accept) { "I agree with these terms" }
  let(:btn_refuse) { "Refuse the terms" }

  before do
    switch_to_host(organization.host)
  end

  describe "When the Organization TOS version is updated" do
    before do
      organization.update!(tos_version: Faker::Date.forward(days: 15))
      login_as user, scope: :user
      visit decidim.root_path
    end

    context "when a user starts a session, has to accept and review them" do
      it "redirects to the TOS page" do
        expect(page).to have_current_path(decidim.page_path(tos_page))
        expect(page).to have_content translated(tos_page.title)
        expect(page.find(".card__content p", obscured: false)).to have_content strip_tags(translated(tos_page.content))
      end

      it "renders an announcement requiring to review the TOS" do
        expect(page).to have_content("Required: Review updates to our terms of service")
      end

      it "renders an announcement advising that TOS has been updated" do
        expect(page).to have_content("We've updated our Terms of Service, please review them.")
      end

      it "shows a button to Agree the updated Terms" do
        expect(page).to have_button btn_accept
      end

      it "shows a button to Refuse Terms" do
        expect(page).to have_button btn_refuse
      end
    end

    context "and the user accepts the updated TOS" do
      before do
        click_button btn_accept
      end

      it "renders a success announcement" do
        expect(page).to have_content("Great! You have accepted the terms and conditions.")
        expect(page).to have_css(".flash.success")
      end
    end

    context "and the user refuses the updated TOS" do
      before do
        click_button btn_refuse
      end

      it "renders a modal" do
        expect(page).to have_css("#tos-refuse-modal")
        expect(page).to have_content("Do you really refuse the updated Terms and Conditions?")
      end

      context "with the refuse modal has different options" do
        it "shows an option to accept the TOS" do
          within "#tos-refuse-modal" do
            expect(page).to have_button("Accept terms and continue")
            expect(page).to have_tag("form", action: decidim.accept_tos_path)
          end
        end

        it "shows an option to download the users data" do
          within "#tos-refuse-modal" do
            expect(page).to have_link("download your data", href: decidim.data_portability_path)
          end
        end

        it "shows an option to logout" do
          within "#tos-refuse-modal" do
            expect(page).to have_button("I'll review it later")
            expect(page).to have_tag("form", action: decidim.destroy_user_session_path)
          end
        end

        it "shows an option delete the account" do
          within "#tos-refuse-modal" do
            expect(page).to have_link("delete your account", href: decidim.delete_account_path)
          end
        end
      end
    end
  end
end
