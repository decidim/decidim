# frozen_string_literal: true

require "spec_helper"

describe "Edit proposals", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:user) { create :user, :confirmed, organization: participatory_process.organization }
  let!(:another_user) { create :user, :confirmed, organization: participatory_process.organization }
  let!(:proposal) { create :proposal, users: [user], component: }
  let!(:proposal_title) { translated(proposal.title) }

  before do
    switch_to_host user.organization.host
  end

  describe "editing my own proposal" do
    let(:new_title) { "This is my proposal new title" }
    let(:new_body) { "This is my proposal new body" }

    before do
      login_as user, scope: :user
    end

    it "can be updated" do
      visit_component

      click_link proposal_title
      click_link "Edit proposal"

      expect(page).to have_content "EDIT PROPOSAL"
      expect(page).not_to have_content("You can move the point on the map.")

      within "form.edit_proposal" do
        fill_in :proposal_title, with: new_title
        fill_in :proposal_body, with: new_body
        click_button "Send"
      end

      expect(page).to have_content(new_title)
      expect(page).to have_content(new_body)
    end

    context "when attachments are allowed" do
      let(:component) { create(:proposal_component, :with_attachments_allowed, participatory_space: participatory_process) }

      before do
        visit_component
        click_link translated(proposal.title)
      end

      it "shows validation error when format is not accepted" do
        click_link "Edit proposal"
        dynamically_attach_file(:proposal_photos, Decidim::Dev.asset("participatory_text.md"), keep_modal_open: true) do
          expect(page).to have_content("Accepted formats: #{Decidim::OrganizationSettings.for(organization).upload_allowed_file_extensions_image.join(", ")}")
        end
        expect(page).to have_content("file should be one of (?-mix:image\\/.*?), (?-mix:application\\/pdf), (?-mix:application\\/rtf), (?-mix:text\\/plain)")
      end

      context "with a file and photo" do
        let!(:file) { create(:attachment, :with_pdf, weight: 1, attached_to: proposal) }
        let!(:photo) { create(:attachment, :with_image, weight: 0, attached_to: proposal) }

        it "can delete attachments" do
          visit current_path
          expect(page).to have_content("RELATED DOCUMENTS")
          expect(page).to have_content("RELATED IMAGES")
          click_link "Edit proposal"

          click_button "Edit documents"
          within ".upload-modal" do
            find("button.remove-upload-item").click
            click_button "Save"
          end
          click_button "Edit image"
          within ".upload-modal" do
            find("button.remove-upload-item").click
            click_button "Save"
          end

          click_button "Send"

          expect(page).to have_no_content("Related documents")
          expect(page).to have_no_content("Related images")
        end

        context "with attachment titles" do
          let(:attachment_file_title) { ::Faker::Lorem.sentence }
          let(:attachment_image_title) { ::Faker::Lorem.sentence }

          it "can change attachment titles" do
            click_link "Edit proposal"
            click_button "Edit image"
            within ".upload-modal" do
              expect(page).to have_content("Preferrably a landscape image that does not have any text")
              find(".attachment-title").set(attachment_image_title)
              click_button "Save"
            end
            click_button "Edit documents"
            within ".upload-modal" do
              expect(page).to have_content("Has to be an image or a document")
              find(".attachment-title").set(attachment_file_title)
              click_button "Save"
            end
            click_button "Send"
            expect(page).to have_selector("div.flash.callout.success")
            expect(Decidim::Attachment.count).to eq(2)
            expect(translated(Decidim::Attachment.find_by(attached_to_id: proposal.id, content_type: "image/jpeg").title)).to eq(attachment_image_title)
            expect(translated(Decidim::Attachment.find_by(attached_to_id: proposal.id, content_type: "application/pdf").title)).to eq(attachment_file_title)
          end
        end
      end

      context "with multiple images" do
        it "can add many images many times" do
          click_link "Edit proposal"
          dynamically_attach_file(:proposal_photos, Decidim::Dev.asset("city.jpeg"))
          dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("icon.png"))
          dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("avatar.jpg"))
          click_button "Send"
          click_link "Edit proposal"
          within ".photos_container" do
            expect(page).to have_content("city.jpeg")
          end
          within ".attachments_container" do
            expect(page).to have_content("icon.png")
            expect(page).to have_content("avatar.jpg")
          end
          dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("city2.jpeg"))
          dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("city3.jpeg"))
          click_button "Send"
          expect(page).to have_selector("div.flash.callout.success")
          expect(page).to have_selector(".thumbnail[alt='city']")
          expect(page).to have_selector(".thumbnail[alt='icon']")
          expect(page).to have_selector(".thumbnail[alt='avatar']")
          expect(page).to have_selector(".thumbnail[alt='city2']")
          expect(page).to have_selector(".thumbnail[alt='city3']")
        end
      end
    end

    context "with geocoding enabled" do
      let(:component) { create(:proposal_component, :with_geocoding_enabled, participatory_space: participatory_process) }
      let(:address) { "6 Villa des Nymphéas 75020 Paris" }
      let(:new_address) { "6 rue Sorbier 75020 Paris" }
      let!(:proposal) { create :proposal, address:, users: [user], component: }
      let(:latitude) { 48.8682538 }
      let(:longitude) { 2.389643 }

      before do
        stub_geocoding(new_address, [latitude, longitude])
      end

      it "can be updated with address", :serves_geocoding_autocomplete do
        visit_component

        click_link translated(proposal.title)
        click_link "Edit proposal"
        check "proposal_has_address"

        expect(page).to have_field("Title", with: translated(proposal.title))
        expect(page).to have_field("Body", with: translated(proposal.body))
        expect(page).to have_field("Address", with: proposal.address)
        expect(page).to have_css("[data-decidim-map]")

        fill_in_geocoding :proposal_address, with: new_address
        expect(page).to have_content("You can move the point on the map.")

        click_button "Send"
        expect(page).to have_content(new_address)
      end

      context "when the address is removed from the form" do
        before do
          proposal.update!(
            address: new_address,
            latitude:,
            longitude:
          )
        end

        it "allows filling an empty address and unchecking the has address checkbox" do
          visit_component

          click_link translated(proposal.title)
          click_link "Edit proposal"

          expect(page).to have_field("Title", with: translated(proposal.title))
          expect(page).to have_field("Body", with: translated(proposal.body))
          expect(page).to have_field("Address", with: proposal.address)

          within "form.edit_proposal" do
            fill_in :proposal_title, with: new_title
            fill_in :proposal_body, with: new_body
            fill_in :proposal_address, with: ""
          end
          uncheck "proposal_has_address"
          click_button "Send"

          expect(page).to have_content(new_title)
          expect(page).to have_content(new_body)
          expect(page).not_to have_content(proposal.address)
        end
      end
    end

    context "when updating with wrong data" do
      let(:component) { create(:proposal_component, :with_creation_enabled, :with_attachments_allowed, participatory_space: participatory_process) }

      it "returns an error message" do
        visit_component

        click_link proposal_title
        click_link "Edit proposal"

        expect(page).to have_content "EDIT PROPOSAL"

        within "form.edit_proposal" do
          fill_in :proposal_body, with: "A"
          click_button "Send"
        end

        # The character counters are doubled because there is a separate screen reader character counter.
        expect(page).to have_content("At least 15 characters", count: 4)

        within "form.edit_proposal" do
          fill_in :proposal_body, with: "WE DO NOT WANT TO SHOUT IN THE PROPOSAL BODY TEXT!"
          click_button "Send"
        end

        expect(page).to have_content("is using too many capital letters (over 25% of the text)")
      end

      it "keeps the submitted values" do
        visit_component

        click_link proposal_title
        click_link "Edit proposal"

        expect(page).to have_content "EDIT PROPOSAL"

        within "form.edit_proposal" do
          fill_in :proposal_title, with: "A title with a #hashtag"
          fill_in :proposal_body, with: "ỲÓÜ WÄNTt TÙ ÚPDÀTÉ À PRÖPÔSÁL"
        end
        click_button "Send"

        expect(page).to have_selector("input[value='A title with a #hashtag']")
        expect(page).to have_content("ỲÓÜ WÄNTt TÙ ÚPDÀTÉ À PRÖPÔSÁL")
      end
    end

    context "when rich text editor is enabled on the frontend" do
      before do
        organization.update(rich_text_editor_in_public_views: true)
      end

      context "when proposal body has link" do
        let(:link) { "http://www.linux.org" }
        let(:body_en) { %(Hello <a href="#{link}" target="_blank">this is a link</a> World) }

        before do
          body = proposal.body
          body["en"] = body_en
          proposal.update!(body:)
          visit_component
          click_link proposal_title
        end

        it "doesnt change the href" do
          click_link "Edit proposal"
          expect(page).to have_link("this is a link", href: link)
        end

        it "doesnt add external link container inside the editor" do
          click_link "Edit proposal"
          editor = page.find(".editor-container")
          expect(editor).to have_selector("a[href='#{link}']")
          expect(editor).not_to have_selector("a.external-link-container")
        end
      end
    end
  end

  describe "editing someone else's proposal" do
    before do
      login_as another_user, scope: :user
    end

    it "renders an error" do
      visit_component

      click_link proposal_title
      expect(page).to have_no_content("Edit proposal")
      visit "#{current_path}/edit"

      expect(page).to have_content("not authorized")
    end
  end

  describe "editing my proposal outside the time limit" do
    let!(:proposal) { create :proposal, users: [user], component:, created_at: 1.hour.ago }

    before do
      login_as another_user, scope: :user
    end

    it "renders an error" do
      visit_component

      click_link proposal_title
      expect(page).to have_no_content("Edit proposal")
      visit "#{current_path}/edit"

      expect(page).to have_content("not authorized")
    end
  end
end
