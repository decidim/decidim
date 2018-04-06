# frozen_string_literal: true

require "spec_helper"

describe Decidim::Consultations::Admin::ConsultationResultsPublicationsController, type: :system do
  include_context "when administrating a consultation"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user, run_callbacks: false
    visit decidim_admin_consultations.consultations_path
  end

  describe "publishing results" do
    let!(:consultation) { create(:consultation, :finished, :unpublished_results, organization: organization) }

    before do
      click_link translated(consultation.title)
    end

    it "publishes the consultation" do
      click_link "Publish results"
      expect(page).to have_content("published successfully")
      expect(page).to have_content("Unpublish results")
      expect(page).to have_current_path decidim_admin_consultations.edit_consultation_path(consultation)

      consultation.reload
      expect(consultation).to be_results_published
    end
  end

  describe "unpublishing results" do
    let!(:consultation) { create(:consultation, :published_results, :finished, organization: organization) }

    before do
      click_link translated(consultation.title)
    end

    it "unpublishes the results" do
      click_link "Unpublish results"
      expect(page).to have_content("unpublished successfully")
      expect(page).to have_content("Publish results")
      expect(page).to have_current_path decidim_admin_consultations.edit_consultation_path(consultation)

      consultation.reload
      expect(consultation).not_to be_results_published
    end
  end
end
