# frozen_string_literal: true

require "spec_helper"

describe "User edit meeting", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:user) { create :user, :confirmed, organization: participatory_process.organization }
  let!(:another_user) { create :user, :confirmed, organization: participatory_process.organization }
  let!(:meeting) { create :meeting, title: "Meeting title with #hashtag", description: "Meeting description", component: component }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

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

      click_link meeting.title
      click_link "Edit Meeting"

      expect(page).to have_content "EDIT YOUR MEETING"

      within "form.edit_meeting" do
        fill_in :meeting_title, with: new_title
        fill_in :meeting_description, with: new_description
        click_button "Update"
      end

      expect(page).to have_content(new_title)
      expect(page).to have_content(new_description)
    end

    context "when updating with wrong data" do
      let(:component) do
        create(:meeting_component,
               # :with_creation_enabled,
               participatory_space: participatory_process)
      end

      it "returns an error message" do
        visit_component

        click_link meeting.title
        click_link "Edit Meeting"

        expect(page).to have_content "EDIT YOUR MEETING"

        within "form.edit_meeting" do
          fill_in :meeting_description, with: " "
          click_button "Update"
        end

        expect(page).to have_content("problem updating")
      end
    end
  end

  describe "editing someone else's meeting" do
    before do
      login_as another_user, scope: :user
    end

    xit "renders an error" do
      visit_component

      click_link meeting.title
      expect(page).to have_no_content("Edit meeting")
      visit current_path + "/edit"

      expect(page).to have_content("not authorized")
    end
  end

  describe "editing my meeting outside the time limit" do
    let!(:meeting) { create :meeting, users: [user], component: component, created_at: 1.hour.ago }

    before do
      login_as another_user, scope: :user
    end

    xit "renders an error" do
      visit_component

      click_link meeting.title
      expect(page).to have_no_content("Edit meeting")
      visit current_path + "/edit"

      expect(page).to have_content("not authorized")
    end
  end
end
