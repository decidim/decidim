# frozen_string_literal: true

require "spec_helper"

describe "User edit meeting" do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:user) { create(:user, :confirmed, organization: participatory_process.organization) }
  let!(:another_user) { create(:user, :confirmed, organization: participatory_process.organization) }
  let!(:meeting) { create(:meeting, :published, title: { en: "Meeting with a title" }, description: { en: "Meeting description" }, author: user, component:) }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:component) do
    create(:meeting_component,
           participatory_space: participatory_process,
           settings: { creation_enabled_for_participants: true, taxonomy_filters: taxonomy_filter_ids })
  end
  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
  let(:taxonomy_filter_ids) { [taxonomy_filter.id] }

  before do
    switch_to_host user.organization.host
    stub_geocoding_coordinates([meeting.latitude, meeting.longitude])
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

      click_on translated(meeting.title)
      find("#dropdown-trigger-resource-#{meeting.id}").click
      click_on "Edit"

      expect(page).to have_content "Edit Your Meeting"

      within "form.meetings_form" do
        fill_in :meeting_title, with: new_title
        fill_in :meeting_description, with: new_description
        select decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}"

        click_on "Update"
      end

      expect(page).to have_content(new_title)
      expect(page).to have_content(new_description)
      expect(page).to have_content(decidim_sanitize_translated(taxonomy.name))
    end

    context "when using the front-end geocoder" do
      it_behaves_like(
        "a record with front-end geocoding address field",
        Decidim::Meetings::Meeting,
        within_selector: "form.meetings_form",
        address_field: :meeting_address
      ) do
        let(:geocoded_address_value) { meeting.address }
        let(:geocoded_address_coordinates) { [latitude, longitude] }

        before do
          stub_geocoding_coordinates([latitude, longitude])
          # Prepare the view for submission (other than the address field)
          visit_component

          click_on translated(meeting.title)
          find("#dropdown-trigger-resource-#{meeting.id}").click
          click_on "Edit"

          expect(page).to have_content "Edit Your Meeting"
        end
      end
    end

    context "when updating with wrong data" do
      it "returns an error message" do
        visit_component

        click_on translated(meeting.title)
        find("#dropdown-trigger-resource-#{meeting.id}").click
        click_on "Edit"

        expect(page).to have_content "Edit Your Meeting"

        within "form.meetings_form" do
          fill_in :meeting_description, with: " "
          click_on "Update"
        end

        expect(page).to have_content("problem updating")
      end
    end

    context "when rich_text_editor_in_public_views is disabled" do
      before { organization.update(rich_text_editor_in_public_views: false) }

      it "displays the description not wrapped in ProseMirror div" do
        visit_component

        click_on translated(meeting.title)
        find("#dropdown-trigger-resource-#{meeting.id}").click
        click_on "Edit"

        expect(page).to have_content "Edit Your Meeting"

        within "form.meetings_form" do
          expect(page).to have_no_css("div.editor-input")
        end

        within "textarea#meeting_description" do
          expect(page).to have_content translated(meeting.description)
          expect(page).to have_no_content '<div class="editor-input">'
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

      click_on translated(meeting.title)
      expect(page).to have_no_content("Edit meeting")
      visit "#{current_path}/edit"

      expect(page).to have_content("not authorized")
    end
  end
end
