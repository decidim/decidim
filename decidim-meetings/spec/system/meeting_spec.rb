# frozen_string_literal: true

require "spec_helper"

describe "Meeting", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:services) do
    [
      { title: Decidim::Faker::Localized.sentence(2), description: Decidim::Faker::Localized.sentence(5) },
      { title: Decidim::Faker::Localized.sentence(2), description: Decidim::Faker::Localized.sentence(5) }
    ]
  end

  let(:meeting) { create :meeting, services: services, component: component }
  let!(:user) { create :user, :confirmed, organization: organization }

  def visit_meeting
    visit resource_locator(meeting).path
  end

  context "when meeting has services" do
    it "they show it" do
      visit_meeting

      within ".view-side .card--list" do
        expect(page).to have_selector(".card--list__item", count: services.size)

        services_titles = services.map { |service| service[:title][:en] }
        services_present_in_pages = current_scope.all(".card--list__heading").map(&:text)
        expect(services_titles).to include(*services_present_in_pages)
      end
    end
  end

  context "when the user is logged in and is registered to the meeting" do
    let!(:registration) { create(:registration, meeting: meeting, user: user) }

    before do
      login_as user, scope: :user
    end

    it "shows the registration code" do
      visit_meeting

      expect(page).to have_css(".registration_code")
      expect(page).to have_content(registration.code)
    end

    context "when showing the registration code validation state" do
      it "shows validation pending if not validated" do
        visit_meeting

        expect(registration.validated_at).to be(nil)
        expect(page).to have_content("VALIDATION PENDING")
      end

      it "shows validated if validated" do
        registration.update validated_at: Time.current
        visit_meeting

        expect(registration.validated_at).not_to be(nil)
        expect(page).to have_content("VALIDATED")
      end
    end
  end
end
