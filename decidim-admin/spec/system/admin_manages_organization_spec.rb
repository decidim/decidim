# frozen_string_literal: true

require "spec_helper"

describe "Admin manages organization", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

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

        it "deletes paragraph changes pressing backspace" do
          find('div[contenteditable="true"].ql-editor').native.send_keys "ef", [:enter], "gh", [:backspace], [:backspace], [:backspace], [:backspace]
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq("<p>e</p>".gsub("\n", ""))
        end

        it "deletes linebreaks when pressing backspace" do
          find('div[contenteditable="true"].ql-editor').native.send_keys "a", [:left], [:enter], [:shift, :enter], [:backspace], [:backspace]
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq("<p>a</p>".gsub("\n", ""))
        end

        it "creates and deletes linebreaks with enter, shift+enter and backspace" do
          find('div[contenteditable="true"].ql-editor').native.send_keys "acd", [:left], [:left], [:enter], [:shift, :enter], [:shift, :enter], "b", [:left], [:backspace], [:backspace]
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq("<p>abcd</p>".gsub("\n", ""))
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

      context "when the admin terms of use content has an br tags" do
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
            <p>Some<br>text<br>here</p>
            <p>Another paragraph</p>
          HTML
        end

        it "renders br tags inside the editor" do
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq(terms_content.gsub("\n", ""))
        end
      end

      context "when the admin terms of use content has a link" do
        let(:terms_content) do
          <<~HTML
            <p>foo<br><a href="https://www.decidim.org" rel="noopener noreferrer" target="_blank">link</a></p>
          HTML
        end
        let(:organization) do
          create(
            :organization,
            admin_terms_of_use_body: Decidim::Faker::Localized.localized { terms_content }
          )
        end

        it "creates single br tag" do
          find('div[contenteditable="true"].ql-editor').native.send_keys([:left, :left, :left, :left, :left], [:shift, :enter])
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq('<p>foo<br><br><a href="https://www.decidim.org" rel="noopener noreferrer" target="_blank">link</a></p>')
        end

        it "doesnt create br tag inside a tag" do
          find('div[contenteditable="true"].ql-editor').native.send_keys([:left, :left, :left, :left], [:shift, :enter])
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq('<p>foo<br><br><a href="https://www.decidim.org" rel="noopener noreferrer" target="_blank">link</a></p>')
        end
      end

      context "when the admin terms of use content has linebreaks inside different formattings" do
        let(:terms_content) do
          <<~HTML
            <p>foo</p>
            <h1><br></h1>
            <p><strong><br></strong></p>
            <p><u><br></u></p>
            <p><em><br></em></p>
          HTML
        end

        let(:organization) do
          create(
            :organization,
            admin_terms_of_use_body: Decidim::Faker::Localized.localized { terms_content }
          )
        end

        it "is still editable" do
          find('div[contenteditable="true"].ql-editor').native.send_keys(Array.new(15) { :backspace }, "bar baz")
          click_button "Update"
          expect(page).to have_content("Organization updated successfully")
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq("<p>bar baz</p>")
        end
      end

      context "when adding br tags to terms of use content" do
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
            <p>Some<br>text<br>here</p>
            <p>Another paragraph</p>
          HTML
        end

        it "renders new br tags inside the editor" do
          find('div[contenteditable="true"].ql-editor').native.send_keys [:enter], "Here shift+enter makes line change:", [:shift, :enter], "instead of new paragraph!"
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq("#{terms_content}<p>Here shift+enter makes line change:<br>instead of new paragraph!</p>".gsub("\n", ""))
        end

        it "makes smartbreak (<br>) when pressing ⏎ button" do
          find('div[contenteditable="true"].ql-editor').native.send_keys [:enter], "foo"
          click_button("⏎")
          find('div[contenteditable="true"].ql-editor').native.send_keys "bar"
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq("#{terms_content}<p>foo<br>bar</p>".gsub("\n", ""))
        end

        describe "editor history" do
          it "has undo" do
            find('div[contenteditable="true"].ql-editor').native.send_keys(
              "foo",
              [:shift, :enter],
              "bar",
              [:control, "z"],
              [:control, "z"],
              [:control, "z"],
              [:control, "z"],
              [:control, "z"],
              [:control, "z"],
              [:control, "z"]
            )
            expect(find(
              "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
            )["innerHTML"]).to eq(terms_content.gsub("\n", ""))
          end

          it "has redo" do
            find('div[contenteditable="true"].ql-editor').native.send_keys [:shift, :enter], "X", [:control, "z"], [:control, :shift, "z"]
            expect(find(
              "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
            )["innerHTML"]).to eq("<p>Paragraph</p><p>Some<br>text<br>here</p><p>Another paragraph<br>X</p>".gsub("\n", ""))
          end
        end
      end

      context "when modifying list using rich text editor" do
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
            <p>Paragraph</p><ul>
            <li>List item 1</li>
            <li>List item 2</li>
            <li>List item 3</li></ul>
          HTML
        end

        it "renders new list item" do
          find('div[contenteditable="true"].ql-editor').native.send_keys [:enter], "List item 4"
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq("<p>Paragraph</p><ul><li>List item 1</li><li>List item 2</li><li>List item 3</li><li>List item 4</li></ul>".gsub("\n", ""))
        end

        it "ends the list when pressing enter twice and starts new paragraph" do
          find('div[contenteditable="true"].ql-editor').native.send_keys [:enter, :enter], "Another paragraph"
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq("#{terms_content}<p>Another paragraph</p>".gsub("\n", ""))
        end

        it "deletes empty list item when pressing backspace and starts new paragraph" do
          find('div[contenteditable="true"].ql-editor').native.send_keys [:enter, :backspace], "Another paragraph"
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq("#{terms_content}<p>Another paragraph</p>".gsub("\n", ""))
        end

        it "deletes linebreaks (and smartbreaks) using the backspace" do
          find('div[contenteditable="true"].ql-editor').native.send_keys [:enter, :enter, :enter, :backspace, :backspace]
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq(terms_content.to_s.gsub("\n", ""))
        end

        it "keeps right curson position when using the backspace" do
          find('div[contenteditable="true"].ql-editor').native.send_keys [:enter, "bc", :left, :left, :enter, :backspace, :backspace, "a"]
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq("<p>Paragraph</p><ul><li>List item 1</li><li>List item 2</li><li>List item 3</li><li>abc</li></ul>".to_s.gsub("\n", ""))
        end

        it "keeps right format when using the backspace" do
          find('div[contenteditable="true"].ql-editor').native.send_keys [:enter, :backspace, "abc", :left, :left, :left, :backspace]
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq("<p>Paragraph</p><ul><li>List item 1</li><li>List item 2</li><li>List item 3abc</li></ul>".to_s.gsub("\n", ""))
        end

        it "keeps right cursor position when using backspace after empty list item" do
          find('div[contenteditable="true"].ql-editor').native.send_keys [:enter, "bcd", :left, :left, :left, :enter, :backspace, :enter, :enter, :backspace, :backspace, :backspace, "a"]
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq("<p>Paragraph</p><ul><li>List item 1</li><li>List item 2</li><li>List item 3</li><li>abcd</li></ul>".to_s.gsub("\n", ""))
        end

        it "keeps right cursor position when using backspace after list item with text" do
          find('div[contenteditable="true"].ql-editor').native.send_keys [:enter, "acd", :left, :left, :enter, :backspace, :enter, :enter, :backspace, :backspace, :backspace, "b"]
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq("<p>Paragraph</p><ul><li>List item 1</li><li>List item 2</li><li>List item 3</li><li>abcd</li></ul>".to_s.gsub("\n", ""))
        end

        it "doesnt delete characters below when pressing backspace" do
          find('div[contenteditable="true"].ql-editor').native.send_keys [:up, :up, :up, :home, :enter, :enter, :enter, :backspace, :backspace, :backspace]
          expect(find(
            "#organization-admin_terms_of_use_body-tabs-admin_terms_of_use_body-panel-0 .editor .ql-editor"
          )["innerHTML"]).to eq(terms_content.to_s.gsub("\n", ""))
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

      it "allows re-sending the form in case there was an error on the form" do
        visit decidim_admin.edit_organization_path
        check "Send welcome notification"
        check "Customize welcome notification"

        fill_in_i18n :organization_welcome_notification_subject, "#organization-welcome_notification_subject-tabs",
                     en: ""

        click_button "Update"
        expect(page).to have_content("There was a problem updating this organization.")

        fill_in_i18n :organization_welcome_notification_subject, "#organization-welcome_notification_subject-tabs",
                     en: "Well hello!"

        click_button "Update"
        expect(page).to have_content("updated successfully")

        organization.reload
        expect(organization.send_welcome_notification).to be_truthy
        expect(organization[:welcome_notification_subject]).to include("en" => "Well hello!")
      end
    end
  end
end
