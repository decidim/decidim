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
    let!(:meetings) { create_list(:meeting, 3, services: services, component: component) }
    let!(:component) do
      create(:component,
             manifest: manifest,
             participatory_space: participatory_space)
    end

    it "doesn't displays comments count" do
      component.update!(settings: { comments_enabled: false })
      visit_component

      meetings.each do |meeting|
        expect(page).not_to have_link(resource_locator(meeting).path)
      end
    end
  end
end
