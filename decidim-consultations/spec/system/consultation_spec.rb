# frozen_string_literal: true

require "spec_helper"

describe "Consultation", type: :system do
  let(:organization) { create(:organization) }
  let(:consultation) { create(:consultation, :published, organization: organization) }

  before do
    switch_to_host(organization.host)
    visit decidim_consultations.consultation_path(consultation)
  end

  it "Shows the basic consultation data" do
    expect(page).to have_i18n_content(consultation.title)
    expect(page).to have_i18n_content(consultation.subtitle)
    expect(page).to have_i18n_content(consultation.description)
  end

  context "when the consultation is unpublished" do
    let!(:consultation) do
      create(:consultation, :unpublished, organization: organization)
    end

    before do
      switch_to_host(organization.host)
      visit decidim_consultations.consultation_path(consultation)
    end

    it "redirects to root path" do
      expect(page).to have_current_path("/")
    end
  end

  context "when highlighted questions" do
    let!(:question) { create(:question, :published, consultation: consultation, scope: consultation.highlighted_scope) }

    before do
      switch_to_host(organization.host)
      visit decidim_consultations.consultation_path(consultation)
    end

    it "Shows the highlighted questions section" do
      expect(page).to have_content("Consultations from #{translated consultation.highlighted_scope.name}".upcase)
    end

    it "shows highlighted question details" do
      expect(page).to have_i18n_content(question.title)
      expect(page).to have_i18n_content(question.subtitle)
    end
  end

  context "when regular questions" do
    let!(:scope) { create(:scope, organization: organization) }
    let!(:question) { create(:question, :published, consultation: consultation, scope: scope) }

    before do
      switch_to_host(organization.host)
      visit decidim_consultations.consultation_path(consultation)
    end

    it "Shows the regular questions section" do
      expect(page).to have_content("OTHER CONSULTATIONS")
    end

    it "shows the scope name" do
      expect(page).to have_content(scope.name["en"].upcase)
    end

    it "shows the question details" do
      expect(page).to have_i18n_content(question.title)
      expect(page).to have_i18n_content(question.subtitle)
    end
  end

  context "when finished consultations" do
    let!(:finished_consultation) { create :consultation, :finished, :published, :published_results, organization: organization }

    before do
      switch_to_host(organization.host)
      visit decidim_consultations.consultation_path(consultation)
    end

    it "consultation page contains finished consultations" do
      expect(page).to have_content("SEE PREVIOUS CONSULTATIONS")
    end
  end
end
