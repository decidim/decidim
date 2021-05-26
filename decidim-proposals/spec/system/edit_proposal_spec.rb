# frozen_string_literal: true

require "spec_helper"

describe "Edit proposals", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:user) { create :user, :confirmed, organization: participatory_process.organization }
  let!(:another_user) { create :user, :confirmed, organization: participatory_process.organization }
  let!(:proposal) { create :proposal, users: [user], component: component }
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

      within "form.edit_proposal" do
        fill_in :proposal_title, with: new_title
        fill_in :proposal_body, with: new_body
        click_button "Send"
      end

      expect(page).to have_content(new_title)
      expect(page).to have_content(new_body)
    end

    context "with attachments allowed" do
      let(:component) { create(:proposal_component, :with_attachments_allowed, participatory_space: participatory_process) }
      let!(:file) { create(:attachment, :with_pdf, attached_to: proposal) }
      let!(:photo) { create(:attachment, :with_image, attached_to: proposal) }

      it "can delete attachments" do
        visit_component
        click_link translated(proposal.title)
        expect(page).to have_content("RELATED DOCUMENTS")
        expect(page).to have_content("RELATED IMAGES")
        click_link "Edit proposal"

        within "#attachment_#{file.id}" do
          click_button "Delete Document"
        end

        within "#attachment_#{photo.id}" do
          click_button "Delete Image"
        end

        click_button "Send"

        expect(page).to have_no_content("Related documents")
        expect(page).to have_no_content("Related images")
      end
    end

    context "with geocoding enabled" do
      let(:component) { create(:proposal_component, :with_geocoding_enabled, participatory_space: participatory_process) }
      let(:address) { "6 Villa des Nymphéas 75020 Paris" }
      let(:new_address) { "6 rue Sorbier 75020 Paris" }
      let!(:proposal) { create :proposal, address: address, users: [user], component: component }
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

        fill_in_geocoding :proposal_address, with: new_address

        click_button "Send"
        expect(page).to have_content(new_address)
      end

      context "when the address is removed from the form" do
        before do
          proposal.update!(
            address: new_address,
            latitude: latitude,
            longitude: longitude
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

        expect(page).to have_content("At least 15 characters", count: 2)

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
    let!(:proposal) { create :proposal, users: [user], component: component, created_at: 1.hour.ago }

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
