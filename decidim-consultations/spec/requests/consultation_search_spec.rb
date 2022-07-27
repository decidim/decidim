# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Consultation search", type: :request do
  subject { response.body }

  let(:organization) { create(:organization) }
  let!(:consultation1) { create(:consultation, :published, title: { en: "A doggo in the title" }, organization:) }
  let!(:consultation2) { create(:consultation, :published, subtitle: { en: "A doggo in the subtitle" }, organization:) }
  let!(:consultation3) { create(:consultation, :published, description: { en: "There is a doggo in the office" }, organization:) }
  let!(:active_consultation) { create(:consultation, :published, :active, organization:) }
  let!(:upcoming_consultation) { create(:consultation, :published, :upcoming, organization:) }
  let!(:finished_consultation) { create(:consultation, :published, :finished, organization:) }
  let!(:unpublished_consultation) { create(:consultation, :unpublished, organization:) }

  let(:filter_params) { {} }
  let(:request_path) { decidim_consultations.consultations_path }

  before do
    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => organization.host }
    )
  end

  it "displays all published consultations by default" do
    expect(subject).to include(translated(consultation1.title))
    expect(subject).to include(translated(consultation2.title))
    expect(subject).to include(translated(consultation3.title))
    expect(subject).to include(translated(active_consultation.title))
    expect(subject).to include(translated(upcoming_consultation.title))
    expect(subject).to include(translated(finished_consultation.title))
    expect(subject).not_to include(translated(unpublished_consultation.title))
  end

  context "when filtering by text" do
    let(:filter_params) { { search_text_cont: "doggo" } }

    it "displays the consultations containing the search in the title, subtitle or the description" do
      expect(subject).to include(translated(consultation1.title))
      expect(subject).to include(translated(consultation2.title))
      expect(subject).to include(translated(consultation3.title))
      expect(subject).not_to include(translated(active_consultation.title))
      expect(subject).not_to include(translated(upcoming_consultation.title))
      expect(subject).not_to include(translated(finished_consultation.title))
      expect(subject).not_to include(translated(unpublished_consultation.title))
    end
  end

  context "when filtering by date" do
    let(:filter_params) { { with_any_date: date } }

    context "and the state is active" do
      let(:date) { "active" }

      it "returns the active consultations" do
        expect(subject).to include(translated(consultation1.title))
        expect(subject).to include(translated(consultation2.title))
        expect(subject).to include(translated(consultation3.title))
        expect(subject).to include(translated(active_consultation.title))
        expect(subject).not_to include(translated(upcoming_consultation.title))
        expect(subject).not_to include(translated(finished_consultation.title))
        expect(subject).not_to include(translated(unpublished_consultation.title))
      end
    end

    context "and the state is upcoming" do
      let(:date) { "upcoming" }

      it "returns the upcoming consultations" do
        expect(subject).not_to include(translated(consultation1.title))
        expect(subject).not_to include(translated(consultation2.title))
        expect(subject).not_to include(translated(consultation3.title))
        expect(subject).not_to include(translated(active_consultation.title))
        expect(subject).to include(translated(upcoming_consultation.title))
        expect(subject).not_to include(translated(finished_consultation.title))
        expect(subject).not_to include(translated(unpublished_consultation.title))
      end
    end

    context "and the state is finished" do
      let(:date) { "finished" }

      it "returns the finished consultations" do
        expect(subject).not_to include(translated(consultation1.title))
        expect(subject).not_to include(translated(consultation2.title))
        expect(subject).not_to include(translated(consultation3.title))
        expect(subject).not_to include(translated(active_consultation.title))
        expect(subject).not_to include(translated(upcoming_consultation.title))
        expect(subject).to include(translated(finished_consultation.title))
        expect(subject).not_to include(translated(unpublished_consultation.title))
      end
    end

    context "and the state is all" do
      let(:date) { "all" }

      it "returns the all consultations" do
        expect(subject).to include(translated(consultation1.title))
        expect(subject).to include(translated(consultation2.title))
        expect(subject).to include(translated(consultation3.title))
        expect(subject).to include(translated(active_consultation.title))
        expect(subject).to include(translated(upcoming_consultation.title))
        expect(subject).to include(translated(finished_consultation.title))
        expect(subject).not_to include(translated(unpublished_consultation.title))
      end
    end
  end
end
