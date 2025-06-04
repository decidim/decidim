# frozen_string_literal: true

require "spec_helper"

describe "User edit meeting" do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:user) { create(:user, :confirmed, organization: participatory_process.organization) }
  let!(:another_user) { create(:user, :confirmed, organization: participatory_process.organization) }
  let!(:meeting) do
    create(:meeting,
           :published,
           :past,
           title: { en: "Meeting with title" },
           description: { en: "Meeting description" },
           author: user,
           component:)
  end
  let(:component) do
    create(:meeting_component,
           :with_creation_enabled,
           participatory_space: participatory_process)
  end

  before do
    stub_geocoding_coordinates([meeting.latitude, meeting.longitude])
    switch_to_host user.organization.host
  end

  describe "closing my own meeting" do
    let(:closing_report) { "The meeting went pretty well, yep." }
    let(:edit_closing_report) { "The meeting went pretty well, yep." }

    before do
      login_as user, scope: :user
    end

    it "updates the related attributes" do
      visit_component

      click_on translated(meeting.title)
      find("#dropdown-trigger-resource-#{meeting.id}").click
      click_on "Close"

      expect(page).to have_content "Close meeting"

      within "form.edit_close_meeting" do
        expect(page).to have_content "Proposals"

        fill_in :close_meeting_closing_report, with: closing_report
        fill_in :close_meeting_attendees_count, with: 10

        click_on "Close meeting"
      end

      expect(page).to have_content(closing_report)
      expect(page).to have_no_content "Close meeting"
      expect(page).to have_no_content "Organizations"
      expect(meeting.reload.closed_at).not_to be_nil
    end

    it "updates without any tags" do
      visit_component

      click_on translated(meeting.title)
      find("#dropdown-trigger-resource-#{meeting.id}").click
      click_on "Close"

      expect(page).to have_content "Close meeting"

      within "form.edit_close_meeting" do
        expect(page).to have_content "Proposals"

        fill_in :close_meeting_closing_report, with: closing_report
        fill_in :close_meeting_attendees_count, with: 10

        click_on "Close meeting"
      end

      meeting.reload
      meeting.update(closing_report: {
                       en: %(#{closing_report} <img src="https://www.example.org/foobar.png" />),
                       es: "El encuentro fue genial",
                       ca: "La trobada va ser genial"
                     })

      visit current_path

      expect(page).to have_content(closing_report)
      within ".meeting__agenda-item__description" do
        expect(page).to have_no_css("img")
      end
      expect(page).to have_no_content "Close meeting"
      expect(page).to have_no_content "Organizations"
      expect(meeting.reload.closed_at).not_to be_nil
    end

    context "when there are existing validated registrations" do
      let!(:not_attended_registrations) { create_list(:registration, 3, meeting:, validated_at: nil) }
      let!(:attended_registrations) { create_list(:registration, 2, meeting:, validated_at: Time.current) }

      before do
        visit_component

        click_on translated(meeting.title)
        find("#dropdown-trigger-resource-#{meeting.id}").click
        click_on "Close"
      end

      it "displays by default the number of validated registrations" do
        within "form.edit_close_meeting" do
          expect(page).to have_field :close_meeting_attendees_count, with: "2"
        end
      end
    end

    context "when updates the meeting report" do
      let!(:meeting) do
        create(:meeting,
               :published,
               :past,
               :closed,
               title: { en: "Meeting with title" },
               description: { en: "Meeting description" },
               author: user,
               attendees_count: nil,
               attending_organizations: nil,
               component:)
      end

      it "updates the meeting report" do
        visit_component

        click_on translated(meeting.title)
        find("#dropdown-trigger-resource-#{meeting.id}").click
        click_on "Edit meeting report"

        expect(page).to have_content "Close meeting"

        within "form.edit_close_meeting" do
          expect(page).to have_content "Proposals"

          fill_in :close_meeting_attendees_count, with: 10
          fill_in :close_meeting_closing_report, with: edit_closing_report

          click_on "Close meeting"
        end

        expect(page).to have_content(edit_closing_report)
        expect(page).to have_no_content "Close meeting"
        expect(page).to have_no_content "Organizations"
        expect(meeting.reload.closed_at).not_to be_nil
      end
    end

    context "when the proposal module is not installed" do
      before do
        allow(Decidim).to receive(:module_installed?).and_return(false)
      end

      it "does not display the proposal picker" do
        visit_component

        click_on translated(meeting.title)
        find("#dropdown-trigger-resource-#{meeting.id}").click
        click_on "Close"

        expect(page).to have_content "Close meeting"

        within "form.edit_close_meeting" do
          expect(page).to have_no_content "Proposals"
        end
      end
    end
  end

  describe "closing someone else's meeting" do
    before do
      login_as another_user, scope: :user
    end

    it "does not show the button" do
      visit_component

      click_on translated(meeting.title)
      expect(page).to have_no_content("Close meeting")
    end
  end
end
