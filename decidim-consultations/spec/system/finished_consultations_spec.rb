# frozen_string_literal: true

require "spec_helper"

describe "Finished consultations", type: :system do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  context "when finished consultations" do
    let!(:consultation) do
      create :consultation, :finished, :published, :published_results, organization:
    end

    it "shows them" do
      visit decidim_consultations.consultations_path

      within ".filters" do
        choose "Finished"
      end

      within ".card--consultation" do
        expect(page).to have_content("FINISHED")
        expect(page).to have_i18n_content(consultation.title)
      end
    end
  end

  context "when active consultations" do
    let!(:consultation) do
      create :consultation, :active, :published, :published_results, organization:
    end

    it "shows them" do
      visit decidim_consultations.consultations_path

      within ".card--consultation" do
        expect(page).to have_content("OPEN VOTES")
        expect(page).to have_i18n_content(consultation.title)
      end
    end
  end
end
