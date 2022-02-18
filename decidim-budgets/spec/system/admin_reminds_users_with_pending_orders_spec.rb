# frozen_string_literal: true

require "spec_helper"

describe "Admin reminds users with pending orders", type: :system do
  include_context "when managing a component as an admin"

  let(:organization) { create(:organization) }
  let(:component) { create(:component, organization: organization, manifest_name: "budgets") }
  let(:budget) { create(:budget, component: component) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization, locale: "en") }
  let(:user2) { create(:user, :admin, :confirmed, organization: organization, locale: "en") }
  let!(:order) { create(:order, budget: budget, user: user, created_at: 3.days.ago) }
  let!(:order2) { create(:order, budget: budget, user: user2, created_at: 3.days.ago) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
    click_link "Send voting reminders"
  end

  describe "new vote reminder" do
    it "shows how many people are being reminded" do
      expect(page).to have_content("You are about to send an email reminder to 2 users")
    end
  end

  describe "create vote reminders" do
    include ActiveJob::TestHelper

    after do
      clear_enqueued_jobs
    end

    it "sends reminders" do
      perform_enqueued_jobs { click_button "Send" }
      expect(page).to have_content("2 users will be reminded")

      expect(emails.count).to eq(2)
      emails.each do |email|
        expect(email.subject).to eq("You have an unfinished vote in the participatory budgeting vote")
      end
      expect(last_email_first_link).to eq("/processes/#{component.participatory_space.slug}/f/#{component.id}/budgets/#{budget.id}")
      expect(last_email_link).to eq("/processes/#{component.participatory_space.slug}/f/#{component.id}/")
    end

    it "doesnt send reminders twice" do
      perform_enqueued_jobs { click_button "Send" }
      expect(page).to have_content("2 users will be reminded")
      click_link "Send voting reminders"
      perform_enqueued_jobs { click_button "Send" }
      expect(page).to have_content("0 users will be reminded")
    end
  end
end
