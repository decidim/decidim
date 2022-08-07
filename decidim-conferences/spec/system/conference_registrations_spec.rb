# frozen_string_literal: true

require "spec_helper"

describe "Conference registrations", type: :system do
  let(:organization) { create :organization }
  let(:conferences_count) { 5 }
  let!(:conferences) do
    create_list(:conference, conferences_count, organization:)
  end
  let(:conference) { conferences.first }
  let!(:user) { create :user, :confirmed, organization: }

  let(:registrations_enabled) { true }
  let(:available_slots) { 20 }
  let(:registration_terms) do
    {
      en: "A legal text",
      es: "Un texto legal",
      ca: "Un text legal"
    }
  end
  let(:registration_types_count) { 5 }
  let!(:registration_types) do
    create_list(:registration_type, registration_types_count, conference:)
  end
  let(:registration_type) { registration_types.first }

  def visit_conference
    visit decidim_conferences.conference_path(conference)
  end

  def visit_conference_registration_types
    visit decidim_conferences.conference_registration_types_path(conference)
  end

  def visit_conference_registration_type
    visit decidim_conferences.conference_registration_type_conference_registration_path(conference_slug: conference, registration_type_id: registration_type)
  end

  before do
    switch_to_host(organization.host)

    conference.update!(
      registrations_enabled:,
      available_slots:,
      registration_terms:
    )
  end

  context "when conference registrations are not enabled" do
    let(:registrations_enabled) { false }

    it "the registration button is not visible" do
      visit_conference

      within ".hero__container" do
        expect(page).not_to have_button("REGISTER")
      end
    end
  end

  context "when conference registrations are enabled" do
    context "and the conference has not a slot available" do
      let(:available_slots) { 1 }

      before do
        create(:conference_registration, conference:, user:, registration_type:)
      end

      it "the registration button is disabled" do
        visit_conference_registration_types

        expect(page).to have_css(".conference-registration", count: registration_types_count)

        within ".wrapper" do
          expect(page).to have_css("button[disabled]", text: "NO SLOTS AVAILABLE", count: 5)
        end
      end
    end

    context "and the conference has a slot available" do
      context "and the user is not logged in" do
        it "they have the option to sign in" do
          visit_conference_registration_types

          within ".wrapper" do
            first(:button, "Registration").click
          end

          expect(page).to have_css("#loginModal", visible: :visible)
        end
      end
    end

    context "and the user is logged in" do
      before do
        login_as user, scope: :user
      end

      it "they can join the conference" do
        visit_conference_registration_types

        within "#registration-type-#{registration_type.id}" do
          click_button "Registration"
        end

        within "#conference-registration-confirm-#{registration_type.id}" do
          expect(page).to have_content "A legal text"
          page.find(".button.expanded").click
        end

        expect(page).to have_content("successfully")

        within ".wrapper" do
          expect(page).to have_css(".button", text: "ATTENDING")
          expect(page).to have_css("button[disabled]", text: "REGISTRATION", count: 4)
        end
      end
    end
  end

  context "and the user is going to the conference" do
    before do
      create(:conference_registration, conference:, user:, registration_type:)
      login_as user, scope: :user
    end

    it "they can leave the conference" do
      visit_conference_registration_types

      within "#registration-type-#{registration_type.id}" do
        click_button "Attending"
      end

      expect(page).to have_content("successfully")

      within ".wrapper" do
        expect(page).to have_css(".button", text: "REGISTRATION", count: registration_types_count)
      end
    end
  end

  context "and the user has been invited to the conference" do
    let!(:invite) { create(:conference_invite, user:, registration_type:) }

    it "requires the user to sign in" do
      visit_conference_registration_type
      expect(page).to have_current_path("/users/sign_in")
    end

    context "when the user is signed in" do
      before { login_as user, scope: :user }

      it "accepts the invitation successfully" do
        visit_conference_registration_type
        expect(page).to have_content("successfully")
      end
    end
  end
end
