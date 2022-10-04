# frozen_string_literal: true

require "spec_helper"

describe "User edit meeting", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:user) { create :user, :confirmed, organization: participatory_process.organization }
  let!(:another_user) { create :user, :confirmed, organization: participatory_process.organization }
  let!(:meeting) { create :meeting, :published, title: { en: "Meeting title with #hashtag" }, description: { en: "Meeting description" }, author: user, component: }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:component) do
    create(:meeting_component,
           :with_creation_enabled,
           participatory_space: participatory_process)
  end

  before do
    switch_to_host user.organization.host
    stub_geocoding(meeting.address, [latitude, longitude])
  end

  describe "editing my own meeting" do
    let(:new_title) { "This is my meeting new title" }
    let(:new_description) { "This is my meeting new body" }

    before do
      login_as user, scope: :user
    end

    it "can be updated" do
      visit_component

      click_link translated(meeting.title)
      click_link "Edit meeting"

      expect(page).to have_content "EDIT YOUR MEETING"

      within "form.edit_meeting" do
        fill_in :meeting_title, with: new_title
        fill_in :meeting_description, with: new_description
        click_button "Update"
      end

      expect(page).to have_content(new_title)
      expect(page).to have_content(new_description)
    end

    context "when using the front-end geocoder", :serves_geocoding_autocomplete do
      it_behaves_like(
        "a record with front-end geocoding address field",
        Decidim::Meetings::Meeting,
        within_selector: ".edit_meeting",
        address_field: :meeting_address
      ) do
        let(:geocoded_address_value) { meeting.address }
        let(:geocoded_address_coordinates) { [latitude, longitude] }

        before do
          # Prepare the view for submission (other than the address field)
          visit_component

          click_link translated(meeting.title)
          click_link "Edit meeting"

          expect(page).to have_content "EDIT YOUR MEETING"
        end
      end
    end

    context "when updating with wrong data" do
      it "returns an error message" do
        visit_component

        click_link translated(meeting.title)
        click_link "Edit meeting"

        expect(page).to have_content "EDIT YOUR MEETING"

        within "form.edit_meeting" do
          fill_in :meeting_description, with: " "
          click_button "Update"
        end

        expect(page).to have_content("problem updating")
      end
    end

    context "when rich_text_editor_in_public_views is disabled" do
      before { organization.update(rich_text_editor_in_public_views: false) }

      it "displays the description not wrapped in ql-editor div" do
        visit_component

        click_link translated(meeting.title)
        click_link "Edit meeting"

        expect(page).to have_content "EDIT YOUR MEETING"

        within "form.edit_meeting" do
          expect(page).to have_no_css("div.ql-editor")
        end

        within "textarea#meeting_description" do
          expect(page).to have_content translated(meeting.description)
          expect(page).to have_no_content '<div class="ql-editor ql-reset-decidim">'
        end
      end
    end
  end

  describe "editing someone else's meeting" do
    before do
      login_as another_user, scope: :user
    end

    it "renders an error" do
      visit_component

      click_link translated(meeting.title)
      expect(page).to have_no_content("Edit meeting")
      visit "#{current_path}/edit"

      expect(page).to have_content("not authorized")
    end
  end
end
