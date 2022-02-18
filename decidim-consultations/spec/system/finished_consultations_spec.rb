# frozen_string_literal: true

require "spec_helper"

describe "Finished consultations", type: :system do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  context "when finished consultations" do
    let!(:consultation) do
      create :consultation, :finished, :published, :published_results, organization: organization
    end

    it "shows them" do
      visit decidim_consultations.finished_consultations_path
      expect(page).to have_content("PAST CONSULTATIONS")
      expect(page).to have_i18n_content(consultation.title)
    end
  end

  context "when active consultations" do
    let!(:consultation) do
      create :consultation, :active, :published, :published_results, organization: organization
    end

    it "shows them" do
      visit decidim_consultations.finished_consultations_path
      expect(page).to have_content("ACTIVE CONSULTATIONS")
      expect(page).to have_i18n_content(consultation.title)
    end
  end
end
