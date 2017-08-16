# frozen_string_literal: true

require "spec_helper"

describe "Explore meetings", type: :feature do
  include_context "feature"
  let(:manifest_name) { "meetings" }

  let(:meetings_count) { 5 }
  let!(:meetings) do
    create_list(:meeting, meetings_count, feature: feature)
  end
  let(:meeting) { meetings.first }
  let!(:user) { create :user, :confirmed, organization: organization }

  def visit_meeting
    visit resource_locator(meeting).path
  end

  let(:inscriptions_enabled) { true }
  let(:available_slots) { 20 }
  let(:inscription_terms) do
    {
      en: "A legal text",
      es: "Un texto legal",
      ca: "Un text legal"
    }
  end

  before do
    meeting.update_attributes!(
      inscriptions_enabled: inscriptions_enabled,
      available_slots: available_slots,
      inscription_terms: inscription_terms
    )
  end

  context "when meeting inscriptions are not enabled" do
    let(:inscriptions_enabled) { false }

    it "the inscription button is not visible" do
      visit_meeting

      within ".card.extra" do
        expect(page).not_to have_button("JOIN MEETING")
        expect(page).not_to have_text("20 slots remaining")
      end
    end
  end

  context "when meeting inscriptions are enabled" do
    context "and the meeting has not a slot available" do
      let(:available_slots) { 1 }

      before do
        create(:inscription, meeting: meeting, user: user)
      end

      it "the inscription button is disabled" do
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

          within "#meeting-inscription-confirm" do
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
        create(:inscription, meeting: meeting, user: user)
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
