# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Participatory process search", type: :request do
  subject { response.body }

  let(:organization) { create(:organization) }
  let(:current_user) { create :user, :confirmed, organization: }
  let!(:process1) do
    create(
      :participatory_process,
      :active,
      organization:,
      area: create(:area, organization:),
      scope: create(:scope, organization:)
    )
  end
  let!(:process2) do
    create(
      :participatory_process,
      :active,
      organization:,
      area: create(:area, organization:),
      scope: create(:scope, organization:)
    )
  end
  let!(:past_process) { create(:participatory_process, :past, organization:) }
  let!(:upcoming_process) { create(:participatory_process, :upcoming, organization:) }
  let!(:unpublished_process) do
    create(
      :participatory_process,
      :unpublished,
      organization:
    )
  end

  let(:filter_params) { {} }
  let(:request_path) { decidim_participatory_processes.participatory_processes_path }

  before do
    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => organization.host }
    )
  end

  it "displays all public active processes by default" do
    expect(subject).to include(translated(process1.title))
    expect(subject).to include(translated(process2.title))
    expect(subject).not_to include(translated(past_process.title))
    expect(subject).not_to include(translated(upcoming_process.title))
  end

  context "when filtering by area" do
    let(:filter_params) { { with_area: process1.area.id } }

    it "displays matching assemblies" do
      expect(subject).to include(translated(process1.title))
      expect(subject).not_to include(translated(process2.title))
    end
  end

  context "when filtering by scope" do
    let(:filter_params) { { with_scope: process1.scope.id } }

    it "displays matching assemblies" do
      expect(subject).to include(translated(process1.title))
      expect(subject).not_to include(translated(process2.title))
    end
  end

  context "when filtering by date" do
    let(:filter_params) { { with_date: date } }

    context "and the date is set to active" do
      let(:date) { "active" }

      it "displays all active processes" do
        expect(subject).to include(translated(process1.title))
        expect(subject).to include(translated(process2.title))
        expect(subject).not_to include(translated(past_process.title))
        expect(subject).not_to include(translated(upcoming_process.title))
      end
    end

    context "and the date is set to past" do
      let(:date) { "past" }

      it "displays the past process" do
        expect(subject).not_to include(translated(process1.title))
        expect(subject).not_to include(translated(process2.title))
        expect(subject).to include(translated(past_process.title))
        expect(subject).not_to include(translated(upcoming_process.title))
      end
    end

    context "and the date is set to upcoming" do
      let(:date) { "upcoming" }

      it "displays the upcoming process" do
        expect(subject).not_to include(translated(process1.title))
        expect(subject).not_to include(translated(process2.title))
        expect(subject).not_to include(translated(past_process.title))
        expect(subject).to include(translated(upcoming_process.title))
      end
    end

    context "and the date is set to all" do
      let(:date) { "all" }

      it "displays all public processes" do
        expect(subject).to include(translated(process1.title))
        expect(subject).to include(translated(process2.title))
        expect(subject).to include(translated(past_process.title))
        expect(subject).to include(translated(upcoming_process.title))
      end
    end
  end
end
