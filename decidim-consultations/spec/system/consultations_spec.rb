# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Consultations", type: :system do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  it_behaves_like "shows contextual help" do
    let(:index_path) { decidim_consultations.consultations_path }
    let(:manifest_name) { :consultations }
  end

  context "when ordering by 'Most recent'" do
    let!(:older_consultation) do
      create(:consultation, :published, organization:, created_at: 1.month.ago)
    end

    let!(:recent_consultation) do
      create(:consultation, :published, organization:, created_at: Time.now.utc)
    end

    before do
      switch_to_host(organization.host)
    end

    it_behaves_like "editable content for admins" do
      let(:target_path) { visit decidim_consultations.consultations_path }
    end

    context "when requesting the consultations path" do
      before do
        visit decidim_consultations.consultations_path
      end

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
  end

  context "when ordering by 'Random'" do
    let!(:consultations) { create_list(:consultation, 2, :published, organization:) }

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
