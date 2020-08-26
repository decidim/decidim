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

  context "when component is not commentable" do
    let!(:ressources) { create_list(:meeting, 3, services: services, component: component) }

    it_behaves_like "an uncommentable component"
  end

  context "when the meeting is the same as the current year" do
    let(:meeting) { create(:meeting, component: component, start_time: Time.current) }

    it "doesn't show the year" do
      visit_meeting

      within ".extra__date" do
        expect(page).to have_no_content(meeting.start_time.year)
      end
    end
  end

  context "when the meeting is different from the current year" do
    let(:meeting) { create(:meeting, component: component, start_time: 1.year.ago) }

    it "shows the year" do
      visit_meeting

      within ".extra__date" do
        expect(page).to have_content(meeting.start_time.year)
      end
    end
  end
end
