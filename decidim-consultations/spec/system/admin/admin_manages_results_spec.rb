# frozen_string_literal: true

require "spec_helper"

describe "Admin manages results", type: :system do
  include_context "when administrating a consultation"
  let(:votes) { 0 }
  let(:total_votes) do
    I18n.t("decidim.admin.consultations.results.total_votes", count: votes)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_consultations.results_consultation_path(consultation)
  end

  describe "viewing active consultation" do
    let!(:consultation) { create(:consultation, :active, :unpublished_results, organization:) }

    it "Show votes but not responses" do
      expect(page).to have_content(/#{total_votes}/i)
      expect(page).to have_content(/#{translated(consultation.questions.first.title)}/i)
      expect(page).not_to have_content(/#{translated(consultation.questions.first.responses.first.title)}/i)
    end
  end

  describe "viewing active consultations with votes" do
    let!(:consultation) { create(:consultation, :active, :unpublished_results, organization:) }
    let!(:vote) do
      consultation.questions.first.votes.create(author: user, response: consultation.questions.first.responses.first)
    end
    let(:votes) { consultation.questions.first.total_votes }

    it "Show votes total" do
      visit decidim_admin_consultations.results_consultation_path(consultation)
      expect(page).to have_content(/#{total_votes}/i)
      expect(page).not_to have_content(/#{translated(consultation.questions.first.responses.first.title)}/i)
    end
  end

  describe "viewing finished consultation" do
    let!(:consultation) { create(:consultation, :finished, :unpublished_results, organization:) }

    it "Shows votes and responses" do
      expect(page).to have_content(/#{total_votes}/i)
      expect(page).to have_content(/#{translated(consultation.questions.first.title)}/i)
      expect(page).to have_content(/#{translated(consultation.questions.first.responses.first.title)}/i)
    end
  end

  describe "viewing finished consultations with votes" do
    let!(:consultation) { create(:consultation, :finished, :unpublished_results, organization:) }
    let!(:vote) do
      consultation.questions.first.votes.create(author: user, response: consultation.questions.first.responses.first)
    end
    let(:votes) { consultation.questions.first.total_votes }

    it "Show votes total" do
      visit decidim_admin_consultations.results_consultation_path(consultation)
      expect(page).to have_content(/#{total_votes}/i)
      expect(page).to have_content(/#{translated(consultation.questions.first.responses.first.title)}/i)
    end
  end
end
