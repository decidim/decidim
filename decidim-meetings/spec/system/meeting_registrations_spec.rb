# frozen_string_literal: true

require "spec_helper"

describe "Meeting registrations", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:meetings_count) { 5 }
  let!(:meetings) do
    create_list(:meeting, meetings_count, component: component)
  end
  let(:meeting) { meetings.first }
  let!(:user) { create :user, :confirmed, organization: organization }

  let(:registrations_enabled) { true }
  let(:available_slots) { 20 }
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

  before do
    meeting.update!(
      registrations_enabled: registrations_enabled,
      available_slots: available_slots,
      registration_terms: registration_terms
    )
  end

  context "when meeting registrations are not enabled" do
    let(:registrations_enabled) { false }

    it "the registration button is not visible" do
      visit_meeting

      within ".card.extra" do
        expect(page).not_to have_button("JOIN MEETING")
        expect(page).not_to have_text("20 slots remaining")
      end
    end
  end

  context "when meeting registrations are enabled" do
    context "and the meeting has not a slot available" do
      let(:available_slots) { 1 }

      before do
        create(:registration, meeting: meeting, user: user)
      end

      it "the registration button is disabled" do
        visit_meeting

        within ".card.extra" do
          expect(page).to have_css("button[disabled]", text: "NO SLOTS AVAILABLE")
          expect(page).to have_text("No slots remaining")
        end
      end
    end

    context "and the meeting has a slot available" do
      context "and the user is not logged in" do
        it "they have the option to sign in" do
          visit_meeting

          within ".card.extra" do
            click_button "Join meeting"
          end

          expect(page).to have_css("#loginModal", visible: true)
        end
      end

      context "and the user is logged in" do
        before do
          login_as user, scope: :user
        end

        it "they can join the meeting" do
          visit_meeting

          within ".card.extra" do
            click_button "Join meeting"
          end

          within "#meeting-registration-confirm" do
            expect(page).to have_content "A legal text"
            page.find(".button.expanded").click
          end

          expect(page).to have_content("successfully")

          within ".card.extra" do
            expect(page).to have_css(".button", text: "GOING")
            expect(page).to have_text("19 slots remaining")
          end
        end
      end
    end

    context "and the user is going to the meeting" do
      before do
        create(:registration, meeting: meeting, user: user)
        login_as user, scope: :user
      end

      it "they can leave the meeting" do
        visit_meeting

        within ".card.extra" do
          click_button "Going"
        end

        expect(page).to have_content("successfully")

        within ".card.extra" do
          expect(page).to have_css(".button", text: "JOIN MEETING")
          expect(page).to have_text("20 slots remaining")
        end
      end
    end
  end
end
