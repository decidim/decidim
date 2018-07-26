# frozen_string_literal: true

require "spec_helper"

describe "Conference registrations", type: :system do
  let(:organization) { create :organization }
  let(:conferences_count) { 5 }
  let!(:conferences) do
    create_list(:conference, conferences_count, organization: organization)
  end
  let(:conference) { conferences.first }
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

  def visit_conference
    visit decidim_conferences.conference_path(conference)
  end

  before do
    switch_to_host(organization.host)

    conference.update!(
      registrations_enabled: registrations_enabled,
      available_slots: available_slots,
      registration_terms: registration_terms
    )
  end

  context "when conference registrations are not enabled" do
    let(:registrations_enabled) { false }

    it "the registration button is not visible" do
      visit_conference

      within ".card.extra.join-conference" do
        expect(page).not_to have_button("JOIN CONFERENCE")
        expect(page).not_to have_text("20 slots remaining")
      end
    end
  end

  context "when conference registrations are enabled" do
    context "and the conference has not a slot available" do
      let(:available_slots) { 1 }

      before do
        create(:conference_registration, conference: conference, user: user)
      end

      it "the registration button is disabled" do
        visit_conference

        within ".card.extra.join-conference" do
          expect(page).to have_css("button[disabled]", text: "NO SLOTS AVAILABLE")
          expect(page).to have_text("No slots remaining")
        end
      end
    end

    context "and the conference has a slot available" do
      context "and the user is not logged in" do
        it "they have the option to sign in" do
          visit_conference

          within ".card.extra.join-conference" do
            click_button "Join Conference"
          end

          expect(page).to have_css("#loginModal", visible: true)
        end
      end

      context "and the user is logged in" do
        before do
          login_as user, scope: :user
        end

        it "they can join the conference" do
          visit_conference

          within ".card.extra.join-conference" do
            click_button "Join Conference"
          end

          within "#conference-registration-confirm-#{conference.id}" do
            expect(page).to have_content "A legal text"
            page.find(".button.expanded").click
          end

          expect(page).to have_content("successfully")

          within ".card.extra.join-conference" do
            expect(page).to have_css(".button", text: "GOING")
            expect(page).to have_text("19 slots remaining")
          end
        end
      end
    end

    context "and the user is going to the conference" do
      before do
        create(:conference_registration, conference: conference, user: user)
        login_as user, scope: :user
      end

      it "they can leave the conference" do
        visit_conference

        within ".card.extra.join-conference" do
          click_button "Going"
        end

        expect(page).to have_content("successfully")

        within ".card.extra.join-conference" do
          expect(page).to have_css(".button", text: "JOIN CONFERENCE")
          expect(page).to have_text("20 slots remaining")
        end
      end
    end
  end
end
