# frozen_string_literal: true

require "spec_helper"

describe "Consultations", type: :system do
  let(:organization) { create(:organization) }

  context "when ordering by 'Most recent'" do
    let!(:older_consultation) do
      create(:consultation, :published, organization: organization, created_at: 1.month.ago)
    end

    let!(:recent_consultation) do
      create(:consultation, :published, organization: organization, created_at: Time.now.utc)
    end

    before do
      switch_to_host(organization.host)
      visit decidim_consultations.consultations_path
    end

    it_behaves_like "editable content for admins"

    it "lists the consultations ordered by created at" do
      within ".order-by" do
        expect(page).to have_selector("ul[data-dropdown-menu$=dropdown-menu]", text: "Random")
        page.find("a", text: "Random").click
        click_link "Most recent"
      end

      expect(page).to have_selector("#consultations .card-grid .column:first-child", text: recent_consultation.title[:en])
      expect(page).to have_selector("#consultations .card-grid .column:last-child", text: older_consultation.title[:en])
    end
  end

  context "when ordering by 'Random'" do
    let!(:consultations) { create_list(:consultation, 2, :published, organization: organization) }

    before do
      switch_to_host(organization.host)
      visit decidim_consultations.consultations_path
    end

    it "Shows all consultations" do
      within ".order-by" do
        expect(page).to have_selector("ul[data-dropdown-menu$=dropdown-menu]", text: "Random")
      end

      expect(page).to have_selector(".card--consultation", count: 2)
      expect(page).to have_content(translated(consultations.first.title))
      expect(page).to have_content(translated(consultations.last.title))
    end
  end
end
