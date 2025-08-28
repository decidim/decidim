# frozen_string_literal: true

require "spec_helper"

describe "Edit proposals" do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:user) { create(:user, :confirmed, organization: participatory_process.organization) }
  let!(:another_user) { create(:user, :confirmed, organization: participatory_process.organization) }
  let!(:proposal) { create(:proposal, users: [user], component:) }
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

      click_on proposal_title
      find("#dropdown-trigger-resource-#{proposal.id}").click
      click_on "Edit"

      expect(page).to have_content "Edit proposal"
      expect(page).to have_no_content("You can move the point on the map.")

      within "form.edit_proposal" do
        fill_in :proposal_title, with: new_title
        fill_in :proposal_body, with: new_body
        click_on "Send"
      end

      expect(page).to have_content(new_title)
      expect(page).to have_content(new_body)
    end

    context "when attachments are allowed" do
      let(:component) { create(:proposal_component, :with_attachments_allowed, participatory_space: participatory_process) }

      before do
        visit_component
        click_on translated(proposal.title)
      end

      it "shows validation error when format is not accepted" do
        find("#dropdown-trigger-resource-#{proposal.id}").click
        click_on "Edit"
        dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("dummy-dummies-example.xlsx"), keep_modal_open: true) do
          expect(page).to have_content("Accepted formats: #{Decidim::OrganizationSettings.for(organization).upload_allowed_file_extensions_image.join(", ")}")
        end
        expect(page).to have_content("Validation error!")
      end

      context "with a file and photo" do
        let!(:file) { create(:attachment, :with_pdf, weight: 1, attached_to: proposal) }
        let!(:photo) { create(:attachment, :with_image, weight: 0, attached_to: proposal) }

        it "can delete attachments" do
          visit current_path

          expect(page).to have_content("Documents")
          find("#dropdown-trigger-resource-#{proposal.id}").click
          click_on "Edit"

          click_on("Edit attachments")
          within ".upload-modal" do
            within "[data-filename='city.jpeg']" do
              click_on("Remove")
            end
            within "[data-filename='Exampledocument.pdf']" do
              click_on("Remove")
            end
            click_on "Save"
          end

          click_on "Send"

          expect(page).to have_no_content("Documents")
          expect(page).to have_no_content("Images")
        end

        context "with attachment titles" do
          let(:attachment_file_title) { Faker::Lorem.sentence }
          let(:attachment_image_title) { Faker::Lorem.sentence }

          it "can change attachment titles" do
            find("#dropdown-trigger-resource-#{proposal.id}").click
            click_on "Edit"
            click_on("Edit attachments")
            within ".upload-modal" do
              expect(page).to have_content("Has to be an image or a document")
              expect(page).to have_content("If it is an image, it preferably be a landscape image that does not have any text. The service crops the image.")
              within "[data-filename='city.jpeg']" do
                find("input[type='text']").set(attachment_image_title)
              end
              within "[data-filename='Exampledocument.pdf']" do
                find("input[type='text']").set(attachment_file_title)
              end
              click_on "Save"
            end
            click_on "Send"
            expect(page).to have_css("[data-alert-box].success")
            expect(Decidim::Attachment.count).to eq(2)
            expect(translated(Decidim::Attachment.find_by(attached_to_id: proposal.id, content_type: "image/jpeg").title)).to eq(attachment_image_title)
            expect(translated(Decidim::Attachment.find_by(attached_to_id: proposal.id, content_type: "application/pdf").title)).to eq(attachment_file_title)
          end
        end

        context "with problematic file titles" do
          let!(:photo) { create(:attachment, :with_image, weight: 0, attached_to: proposal) }
          let!(:document) { create(:attachment, :with_pdf, weight: 1, attached_to: proposal) }

          before do
            document.update!(title: { en: "<svg onload=alert('ALERT')>.pdf" })
            photo.update!(title: { en: "<svg onload=alert('ALERT')>.jpg" })
          end

          it "displays them correctly on the edit form" do
            find("#dropdown-trigger-resource-#{proposal.id}").click
            # With problematic code, should raise Selenium::WebDriver::Error::UnexpectedAlertOpenError
            click_on "Edit"
            expect(page).to have_content("Required fields are marked with an asterisk")
            click_on("Edit attachments")
            within "[data-dialog]" do
              click_on("Save")
            end
            click_on("Send")
            expect(page).to have_content("Proposal successfully updated.")
          end
        end

        context "with problematic file names" do
          let!(:photo) { create(:attachment, :with_image, weight: 0, attached_to: proposal) }
          let!(:document) { create(:attachment, :with_pdf, weight: 1, attached_to: proposal) }

          before do
            document.file.blob.update!(filename: "<svg onload=alert('ALERT')>.pdf")
            photo.file.blob.update!(filename: "<svg onload=alert('ALERT')>.jpg")
          end

          it "displays them correctly on the edit form" do
            find("#dropdown-trigger-resource-#{proposal.id}").click
            # With problematic code, should raise Selenium::WebDriver::Error::UnexpectedAlertOpenError
            click_on "Edit"
            expect(page).to have_content("Required fields are marked with an asterisk")
            click_on("Edit attachments")
            within "[data-dialog]" do
              click_on("Save")
            end
            click_on("Send")
            expect(page).to have_content("Proposal successfully updated.")
          end
        end
      end

      context "with multiple images", :slow do
        it "can add many images many times" do
          skip "REDESIGN_PENDING - Flaky test: upload modal fails on GitHub with multiple files https://github.com/decidim/decidim/issues/10961"

          find("#dropdown-trigger-resource-#{proposal.id}").click
          click_on "Edit proposal"
          dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("city.jpeg"))
          dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("icon.png"))
          dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("avatar.jpg"))
          click_on "Send"
          click_on "Edit proposal"
          expect(page).to have_content("city.jpeg")
          expect(page).to have_content("icon.png")
          expect(page).to have_content("avatar.jpg")
          dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("city2.jpeg"))
          expect(page).to have_content("city2.jpeg")
          expect(page).to have_no_content("city3.jpeg")
          dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("city3.jpeg"))
          expect(page).to have_content("city2.jpeg")
          expect(page).to have_content("city3.jpeg")
          click_on "Send"
          expect(page).to have_css("[data-alert-box].success")
          expect(page).to have_css("img.object-cover[alt='city.jpeg']")
          expect(page).to have_css("img.object-cover[alt='icon.png']")
          expect(page).to have_css("img.object-cover[alt='avatar.jpg']")
          expect(page).to have_css("img.object-cover[alt='city2.jpeg']")
          expect(page).to have_css("img.object-cover[alt='city3.jpeg']")
        end
      end
    end

    context "with maps enabled" do
      let(:component) { create(:proposal_component, :with_geocoding_enabled, participatory_space: participatory_process) }
      let(:address) { "6 Villa des Nymphéas 75020 Paris" }
      let(:new_address) { "6 rue Sorbier 75020 Paris" }
      let!(:proposal) { create(:proposal, address:, users: [user], skip_injection: true, component:) }
      let(:latitude) { 48.8682538 }
      let(:longitude) { 2.389643 }

      before do
        stub_geocoding(new_address, [latitude, longitude])
      end

      it "can be updated with address" do
        visit_component

        click_on translated(proposal.title)
        find("#dropdown-trigger-resource-#{proposal.id}").click
        click_on "Edit"

        expect(page).to have_field("Title", with: translated(proposal.title))
        expect(page).to have_field("Body", with: strip_tags(translated(proposal.body)))
        expect(page).to have_field("Address", with: proposal.address)
        expect(page).to have_css("[data-decidim-map]")

        fill_in :proposal_address, with: nil
        fill_in_geocoding :proposal_address, with: new_address
        expect(page).to have_content("You can move the point on the map.")

        # Give time for the screen reader announcement to be added since there
        # is a small delay before the message appears.
        sleep 0.5
        expect(page).to have_content("Marker added to the map.")

        click_on "Send"
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

        it "allows filling an empty address" do
          visit_component

          click_on translated(proposal.title)
          find("#dropdown-trigger-resource-#{proposal.id}").click
          click_on "Edit"

          expect(page).to have_field("Title", with: translated(proposal.title))
          expect(page).to have_field("Body", with: strip_tags(translated(proposal.body)))
          expect(page).to have_field("Address", with: proposal.address)

          within "form.edit_proposal" do
            fill_in :proposal_title, with: new_title
            fill_in :proposal_body, with: new_body
            fill_in :proposal_address, with: ""
          end

          click_on "Send"

          expect(page).to have_content(new_title)
          expect(page).to have_content(new_body)
          expect(page).to have_no_content(proposal.address)
        end
      end
    end

    context "when updating with wrong data" do
      let(:component) { create(:proposal_component, :with_creation_enabled, :with_attachments_allowed, participatory_space: participatory_process) }

      it "returns an error message" do
        visit_component

        click_on proposal_title
        find("#dropdown-trigger-resource-#{proposal.id}").click
        click_on "Edit"

        expect(page).to have_content "Edit proposal"

        within "form.edit_proposal" do
          fill_in :proposal_body, with: "A"
          click_on "Send"
        end

        # The character counters are doubled because there is a separate screen reader character counter.
        expect(page).to have_content("At least 15 characters", count: 4)

        within "form.edit_proposal" do
          fill_in :proposal_body, with: "WE DO NOT WANT TO SHOUT IN THE PROPOSAL BODY TEXT!"
          click_on "Send"
        end

        expect(page).to have_content("is using too many capital letters (over 25% of the text)")
      end

      it "keeps the submitted values" do
        visit_component

        click_on proposal_title
        find("#dropdown-trigger-resource-#{proposal.id}").click
        click_on "Edit"

        expect(page).to have_content "Edit proposal"

        within "form.edit_proposal" do
          fill_in :proposal_title, with: "A proposal with a title"
          fill_in :proposal_body, with: "ỲÓÜ WÄNTt TÙ ÚPDÀTÉ À PRÖPÔSÁL or a COLLABORATIVE DRAFT"
        end
        click_on "Send"

        expect(page).to have_css("input[value='A proposal with a title']")
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
          organization.update(rich_text_editor_in_public_views: true)

          body = proposal.body
          body["en"] = body_en
          proposal.update!(body:)
          visit_component
          click_on proposal_title
          find("#dropdown-trigger-resource-#{proposal.id}").click
          click_on "Edit"
        end

        it_behaves_like "having a rich text editor", "edit_proposal", "basic"

        it "does not change the href" do
          expect(page).to have_link("this is a link", href: link)
        end

        it "does not add external link container inside the editor" do
          editor = page.find(".editor-container")
          expect(editor).to have_css("a[href='#{link}']")
          expect(editor).to have_no_selector("a.external-link-container")
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

      click_on proposal_title
      expect(page).to have_no_content("Edit proposal")
      visit "#{current_path}/edit"

      expect(page).to have_content("not authorized")
    end
  end

  describe "editing my proposal outside the time limit" do
    let!(:proposal) { create(:proposal, users: [user], component:, created_at: 1.hour.ago) }

    before do
      login_as another_user, scope: :user
    end

    it "renders an error" do
      visit_component

      click_on proposal_title
      expect(page).to have_no_content("Edit proposal")
      visit "#{current_path}/edit"

      expect(page).to have_content("not authorized")
    end
  end
end
