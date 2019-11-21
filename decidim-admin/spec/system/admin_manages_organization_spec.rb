# frozen_string_literal: true

require "spec_helper"

describe "Admin manages organization", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "edit" do
    it "updates the values from the form" do
      visit decidim_admin.edit_organization_path

      fill_in "Name", with: "My super-uber organization"

      %w(Twitter Facebook Instagram YouTube GitHub).each do |network|
        click_link network
        fill_in "organization_#{network.downcase}_handler", with: "decidim"
      end

      select "Castellano", from: "Default locale"
      fill_in "Reference prefix", with: "ABC"

      fill_in_i18n_editor :organization_admin_terms_of_use_body, "#organization_admin_terms_of_use_body-tabs",
                          en: "<p>Respect the privacy of others.</p>"

      click_button "Update"
      expect(page).to have_content("updated successfully")
    end
  end

  describe "welcome message" do
    context "when not customizing it" do
      it "doesn't show the customization fields" do
        visit decidim_admin.edit_organization_path
        check "Send welcome notification"
        expect(page).not_to have_content("Welcome notification subject")
        click_button "Update"
        expect(page).to have_content("updated successfully")

        organization.reload
        expect(organization[:welcome_notification_subject]).to be_nil
        expect(organization.send_welcome_notification).to be_truthy
      end

      context "when customizing it" do
        it "shows the custom fields and stores them" do
          visit decidim_admin.edit_organization_path
          check "Send welcome notification"
          check "Customize welcome notification"

          fill_in_i18n :organization_welcome_notification_subject, "#organization-welcome_notification_subject-tabs",
                       en: "Well hello!"

          fill_in_i18n_editor :organization_welcome_notification_body, "#organization-welcome_notification_body-tabs",
                              en: "<p>Body</p>"

          click_button "Update"
          expect(page).to have_content("updated successfully")

          organization.reload
          expect(organization.send_welcome_notification).to be_truthy
          expect(organization[:welcome_notification_subject]).to include("en" => "Well hello!")
          expect(organization[:welcome_notification_body]).to include("en" => "<p>Body</p>")
        end
      end
    end
  end
end
