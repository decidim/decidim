# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Participatory process search" do
  subject { response.body }

  let(:organization) { create(:organization) }
  let(:current_user) { create(:user, :confirmed, organization:) }
  let!(:process1) do
    create(
      :participatory_process,
      :active,
      organization:
    )
  end
  let!(:process2) do
    create(
      :participatory_process,
      :active,
      organization:
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
  let(:request_path) { decidim_participatory_processes.participatory_processes_path(locale: I18n.locale) }

  before do
    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => organization.host }
    )
  end

  it "displays all public active processes by default" do
    expect(subject).to include(decidim_escape_translated(process1.title))
    expect(subject).to include(decidim_escape_translated(process2.title))
    expect(subject).not_to include(decidim_escape_translated(past_process.title))
    expect(subject).not_to include(decidim_escape_translated(upcoming_process.title))
  end

  it_behaves_like "a participatory space search with taxonomies", :participatory_process

  context "when filtering by date" do
    let(:filter_params) { { with_date: date } }

    context "and the date is set to active" do
      let(:date) { "active" }

      it "displays all active processes" do
        expect(subject).to include(decidim_escape_translated(process1.title))
        expect(subject).to include(decidim_escape_translated(process2.title))
        expect(subject).not_to include(decidim_escape_translated(past_process.title))
        expect(subject).not_to include(decidim_escape_translated(upcoming_process.title))
      end
    end

    context "and the date is set to past" do
      let(:date) { "past" }

      it "displays the past process" do
        expect(subject).not_to include(decidim_escape_translated(process1.title))
        expect(subject).not_to include(decidim_escape_translated(process2.title))
        expect(subject).to include(decidim_escape_translated(past_process.title))
        expect(subject).not_to include(decidim_escape_translated(upcoming_process.title))
      end
    end

    context "and the date is set to upcoming" do
      let(:date) { "upcoming" }

      it "displays the upcoming process" do
        expect(subject).not_to include(decidim_escape_translated(process1.title))
        expect(subject).not_to include(decidim_escape_translated(process2.title))
        expect(subject).not_to include(decidim_escape_translated(past_process.title))
        expect(subject).to include(decidim_escape_translated(upcoming_process.title))
      end
    end

    context "and the date is set to all" do
      let(:date) { "all" }

      it "displays all public processes" do
        expect(subject).to include(decidim_escape_translated(process1.title))
        expect(subject).to include(decidim_escape_translated(process2.title))
        expect(subject).to include(decidim_escape_translated(past_process.title))
        expect(subject).to include(decidim_escape_translated(upcoming_process.title))
      end
    end

    context "and the date is set to an unknown value" do
      let(:date) { "foobar" }
      let(:dom) { Nokogiri::HTML(subject) }

      it "displays all public processes" do
        expect(subject).to include(decidim_escape_translated(process1.title))
        expect(subject).to include(decidim_escape_translated(process2.title))
        expect(subject).to include(decidim_escape_translated(past_process.title))
        expect(subject).to include(decidim_escape_translated(upcoming_process.title))
      end

      it "does not cause any display issues" do
        expect(dom.text).not_to include("foobar")
      end
    end
  end
end
