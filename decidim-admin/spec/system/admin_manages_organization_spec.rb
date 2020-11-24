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

      fill_in_i18n_editor :organization_admin_terms_of_use_body, "#organization-admin_terms_of_use_body-tabs",
                          en: "<p>Respect the privacy of others.</p>",
                          es: "<p>Spanish - Respect the privacy of others.</p>"

      click_button "Update"
      expect(page).to have_content("updated successfully")
    end

    context "when using the rich text editor" do
      before do
        visit decidim_admin.edit_organization_path
      end

      context "when the admin terms of use content is empty" do
        let(:organization) do
          create(
            :organization,
            admin_terms_of_use_body: Decidim::Faker::Localized.localized { "" }
          )
        end

        it "renders the editor" do
          expect(page).to have_selector(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor.ql-blank",
            text: ""
          )
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq("<p><br></p>")
        end
      end

      context "when the admin terms of use content has a list" do
        let(:terms_content) do
          # This is actually how the content is saved from quill.js to the Decidim
          # database.
          <<~HTML
            <p>Paragraph</p><ul>
            <li>List item 1</li>
            <li>List item 2</li>
            <li>List item 3</li></ul><p>Another paragraph</p>
          HTML
        end
        let(:organization) do
          create(
            :organization,
            admin_terms_of_use_body: Decidim::Faker::Localized.localized { terms_content }
          )
        end

        it "renders the correct content inside the editor" do
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq(terms_content.gsub("\n", ""))
        end
      end

      context "when the admin terms of use content has an image with an alt tag" do
        let(:another_organization) { create(:organization) }
        let(:image) { create(:attachment, attached_to: another_organization) }
        let(:organization) do
          create(
            :organization,
            admin_terms_of_use_body: Decidim::Faker::Localized.localized { terms_content }
          )
        end
        let(:terms_content) do
          <<~HTML
            <p>Paragraph</p>
            <p><img src="#{image.url}" alt="foo bar"></p>
          HTML
        end

        it "renders an image and its attributes inside the editor" do
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq(terms_content.gsub("\n", ""))
        end
      end
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
