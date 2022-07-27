# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Election search", type: :request do
  include Decidim::ComponentPathHelper

  subject { response.body }

  let(:component) { create :component, manifest_name: "elections" }
  let(:participatory_space) { component.participatory_space }
  let(:organization) { participatory_space.organization }
  let(:filter_params) { {} }

  let!(:active_election1) do
    create(
      :election,
      :published,
      :ongoing,
      component:,
      description: Decidim::Faker::Localized.literal("Chambray chia selvage hammock health goth.")
    )
  end
  let!(:active_election2) do
    create(
      :election,
      :published,
      :ongoing,
      component:,
      description: Decidim::Faker::Localized.literal("Tacos gentrify celiac mixtape.")
    )
  end
  let!(:upcoming_election) do
    create(
      :election,
      :published,
      :upcoming,
      component:,
      description: Decidim::Faker::Localized.literal("Selfies kale chips taxidermy adaptogen.")
    )
  end
  let!(:finished_election) do
    create(
      :election,
      :published,
      :finished,
      component:
    )
  end
  let!(:unpublished_election) do
    create(
      :election,
      :upcoming,
      component:
    )
  end
  let!(:external_election) { create :election }

  let(:request_path) { Decidim::EngineRouter.main_proxy(component).elections_path }

  before do
    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => component.organization.host }
    )
  end

  it "displays all active elections without any filters" do
    expect(subject).to include(translated(active_election1.title))
    expect(subject).to include(translated(active_election2.title))
    expect(subject).not_to include(translated(upcoming_election.title))
    expect(subject).not_to include(translated(finished_election.title))
    expect(subject).not_to include(translated(unpublished_election.title))
    expect(subject).not_to include(translated(external_election.title))
  end

  context "when searching by text" do
    let(:filter_params) { { search_text_cont: "mixtape" } }

    it "displays only the election containing the search_text" do
      expect(subject).not_to include(translated(active_election1.title))
      expect(subject).to include(translated(active_election2.title))
      expect(subject).not_to include(translated(upcoming_election.title))
      expect(subject).not_to include(translated(finished_election.title))
      expect(subject).not_to include(translated(unpublished_election.title))
      expect(subject).not_to include(translated(external_election.title))
    end
  end

  context "when searching by date" do
    let(:filter_params) { { with_any_date: date } }

    context "and the date is active" do
      let(:date) { %w(active) }

      it "only displays active elections" do
        expect(subject).to include(translated(active_election1.title))
        expect(subject).to include(translated(active_election2.title))
        expect(subject).not_to include(translated(upcoming_election.title))
        expect(subject).not_to include(translated(finished_election.title))
        expect(subject).not_to include(translated(unpublished_election.title))
        expect(subject).not_to include(translated(external_election.title))
      end
    end

    context "and the date is finished" do
      let(:date) { %w(finished) }

      it "only displays finished elections" do
        expect(subject).not_to include(translated(active_election1.title))
        expect(subject).not_to include(translated(active_election2.title))
        expect(subject).not_to include(translated(upcoming_election.title))
        expect(subject).to include(translated(finished_election.title))
        expect(subject).not_to include(translated(unpublished_election.title))
        expect(subject).not_to include(translated(external_election.title))
      end
    end

    context "and the date is upcoming" do
      let(:date) { %w(upcoming) }

      it "only displays upcoming elections" do
        expect(subject).not_to include(translated(active_election1.title))
        expect(subject).not_to include(translated(active_election2.title))
        expect(subject).to include(translated(upcoming_election.title))
        expect(subject).not_to include(translated(finished_election.title))
        expect(subject).not_to include(translated(unpublished_election.title))
        expect(subject).not_to include(translated(external_election.title))
      end
    end

    context "and the date is finished or upcoming" do
      let(:date) { %w(finished upcoming) }

      it "only displays finished and upcoming elections" do
        expect(subject).not_to include(translated(active_election1.title))
        expect(subject).not_to include(translated(active_election2.title))
        expect(subject).to include(translated(upcoming_election.title))
        expect(subject).to include(translated(finished_election.title))
        expect(subject).not_to include(translated(unpublished_election.title))
        expect(subject).not_to include(translated(external_election.title))
      end
    end
  end
end
