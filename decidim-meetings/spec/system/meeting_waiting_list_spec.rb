# frozen_string_literal: true

require "spec_helper"

describe "Meeting waiting list" do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:questionnaire) { create(:questionnaire) }
  let!(:question) { create(:questionnaire_question, questionnaire:, position: 0) }
  let!(:meeting) { create(:meeting, :published, component:, questionnaire:) }
  let!(:user) { create(:user, :confirmed, organization:, notifications_sending_frequency: "real_time") }
  let(:registrations_enabled) { true }
  let(:registration_form_enabled) { false }
  let(:available_slots) { 10 }
  let(:registration_terms) do
    {
      en: "A legal text",
      es: "Un texto legal",
      ca: "Un text legal"
    }
  end

  def visit_meeting
    visit resource_locator(meeting).path
  end

  def leave_meeting(user)
    login_as user, scope: :user
    visit_meeting
    click_on "Cancel your registration"
    logout :user
  end

  before do
    stub_geocoding_coordinates([meeting.latitude, meeting.longitude])
    meeting.update!(
      registrations_enabled:,
      registration_form_enabled:,
      available_slots:,
      registration_terms:
    )
  end

  context "when the registration form is enabled" do
    let(:registration_form_enabled) { true }

    context "when the meeting has available slots" do
      before do
        visit_meeting
        login_as user, scope: :user
      end

      it "does not show the join waitlist button" do
        expect(page).to have_no_content("Join the waitlist")
      end
    end

    context "when the meeting has no available slots" do
      before do
        create_list(:registration, available_slots, meeting: meeting)
      end

      context "when the user is not logged in" do
        before do
          visit_meeting
        end

        it "shows the join waitlist button" do
          expect(page).to have_content("Join waitlist")
          expect(page).to have_no_content("You have joined the waiting list for this meeting.")
        end

        it "shows the login modal when clicking the join waitlist button" do
          click_on "Join waitlist"
          expect(page).to have_css("#loginModal", visible: :visible)
          expect(page).to have_content("Please log in")
        end
      end

      context "when the user is logged in" do
        before do
          login_as user, scope: :user
          visit_meeting
        end

        it "shows the join waitlist button" do
          expect(page).to have_content("Join waitlist")
        end

        it "shows the join waitlist registration form when clicking the join waitlist button" do
          click_on "Join waitlist"
          expect(page).to have_i18n_content(questionnaire.title)
          expect(page).to have_i18n_content(questionnaire.description, strip_tags: true)
          expect(page).to have_i18n_content(question.body)
          expect(page).to have_css(".form.response-questionnaire")
        end

        it "can join the waitlist" do
          click_on "Join waitlist"
          fill_in question.body["en"], with: "My first answer"
          check "questionnaire_tos_agreement"
          accept_confirm do
            click_on "Submit"
          end
          expect(page).to have_content("You have joined the meeting waitlist successfully.")
        end
      end
    end
  end

  context "when the meeting is full and a user cancels their registration" do
    context "and there are users on the waiting list" do
      let!(:registrations) { create_list(:registration, available_slots, meeting: meeting) }
      let(:users_on_waitlist) { create_list(:user, 5, :confirmed, organization:) }
      let(:first_waitlist_user) { users_on_waitlist.first }

      let!(:waitlist_entries) do
        users_on_waitlist.map.with_index do |user, index|
          create(:registration, meeting: meeting, user: user, status: "waiting_list", created_at: Time.current - index.minutes)
        end
      end

      let(:earliest_waitlist_entry) { waitlist_entries.min_by(&:created_at) }
      let(:earliest_waitlist_user) { earliest_waitlist_entry.user }

      before do
        perform_enqueued_jobs { Decidim::Meetings::LeaveMeeting.call(meeting, registrations.first.user) }
        sleep 1
        login_as earliest_waitlist_user, scope: :user
      end

      it "displays the registration confirmation" do
        visit_meeting
        email = last_email
        expect(page).to have_content("Your registration and QR code")
        expect(email.subject).to eq("Your meeting's registration has been confirmed")
        expect(email.to).to eq([earliest_waitlist_user.email])
      end
    end
  end
end
