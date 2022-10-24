# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Voting search", type: :request do
  include Decidim::ComponentPathHelper

  subject { response.body }

  let(:organization) { create(:organization) }
  let(:filter_params) { {} }

  let!(:published_voting) { create :voting, :published, title: Decidim::Faker::Localized.localized { "Tacos gentrify celiac mixtape." }, organization: }
  let!(:upcoming_voting) { create :voting, :upcoming, organization: }
  let!(:ongoing_voting) { create :voting, :ongoing, organization: }
  let!(:finished_voting) { create :voting, :finished, organization: }
  let!(:ongoing_online_voting) { create :voting, :ongoing, :online, organization: }
  let!(:ongoing_in_person_voting) { create :voting, :ongoing, :in_person, organization: }
  let!(:ongoing_hybrid_voting) { create :voting, :ongoing, :hybrid, organization: }
  let!(:unpublished_voting) { create :voting, :unpublished, organization: }
  let!(:external_voting) { create :voting, :published }

  let(:request_path) { decidim_votings.votings_path }

  before do
    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => organization.host }
    )
  end

  it "displays all published votings within the organization without any filters" do
    expect(subject).to include(translated(published_voting.title))
    expect(subject).to include(translated(upcoming_voting.title))
    expect(subject).to include(translated(ongoing_voting.title))
    expect(subject).to include(translated(finished_voting.title))
    expect(subject).to include(translated(ongoing_online_voting.title))
    expect(subject).to include(translated(ongoing_in_person_voting.title))
    expect(subject).to include(translated(ongoing_hybrid_voting.title))
    expect(subject).not_to include(translated(unpublished_voting.title))
    expect(subject).not_to include(translated(external_voting.title))
  end

  context "when searching by text" do
    let(:filter_params) { { search_text_cont: "mixtape" } }

    it "displays only the votings containing the search_text" do
      expect(subject).to include(translated(published_voting.title))
      expect(subject).not_to include(translated(upcoming_voting.title))
      expect(subject).not_to include(translated(ongoing_voting.title))
      expect(subject).not_to include(translated(finished_voting.title))
      expect(subject).not_to include(translated(ongoing_online_voting.title))
      expect(subject).not_to include(translated(ongoing_in_person_voting.title))
      expect(subject).not_to include(translated(ongoing_hybrid_voting.title))
      expect(subject).not_to include(translated(unpublished_voting.title))
      expect(subject).not_to include(translated(external_voting.title))
    end
  end

  context "when searching by date" do
    let(:filter_params) { { with_any_date: date } }

    context "and the date is active" do
      let(:date) { %w(active) }

      it "only displays active votings" do
        expect(subject).not_to include(translated(published_voting.title))
        expect(subject).not_to include(translated(upcoming_voting.title))
        expect(subject).to include(translated(ongoing_voting.title))
        expect(subject).not_to include(translated(finished_voting.title))
        expect(subject).to include(translated(ongoing_online_voting.title))
        expect(subject).to include(translated(ongoing_in_person_voting.title))
        expect(subject).to include(translated(ongoing_hybrid_voting.title))
        expect(subject).not_to include(translated(unpublished_voting.title))
        expect(subject).not_to include(translated(external_voting.title))
      end
    end

    context "and the date is finished" do
      let(:date) { %w(finished) }

      it "only displays finished votings" do
        expect(subject).not_to include(translated(published_voting.title))
        expect(subject).not_to include(translated(upcoming_voting.title))
        expect(subject).not_to include(translated(ongoing_voting.title))
        expect(subject).to include(translated(finished_voting.title))
        expect(subject).not_to include(translated(ongoing_online_voting.title))
        expect(subject).not_to include(translated(ongoing_in_person_voting.title))
        expect(subject).not_to include(translated(ongoing_hybrid_voting.title))
        expect(subject).not_to include(translated(unpublished_voting.title))
        expect(subject).not_to include(translated(external_voting.title))
      end
    end

    context "and the date is upcoming" do
      let(:date) { %w(upcoming) }

      it "only displays upcoming votings" do
        expect(subject).to include(translated(published_voting.title))
        expect(subject).to include(translated(upcoming_voting.title))
        expect(subject).not_to include(translated(ongoing_voting.title))
        expect(subject).not_to include(translated(finished_voting.title))
        expect(subject).not_to include(translated(ongoing_online_voting.title))
        expect(subject).not_to include(translated(ongoing_in_person_voting.title))
        expect(subject).not_to include(translated(ongoing_hybrid_voting.title))
        expect(subject).not_to include(translated(unpublished_voting.title))
        expect(subject).not_to include(translated(external_voting.title))
      end
    end

    context "and the date is finished or upcoming" do
      let(:date) { %w(finished upcoming) }

      it "only displays finished and upcoming votings" do
        expect(subject).to include(translated(published_voting.title))
        expect(subject).to include(translated(upcoming_voting.title))
        expect(subject).not_to include(translated(ongoing_voting.title))
        expect(subject).to include(translated(finished_voting.title))
        expect(subject).not_to include(translated(ongoing_online_voting.title))
        expect(subject).not_to include(translated(ongoing_in_person_voting.title))
        expect(subject).not_to include(translated(ongoing_hybrid_voting.title))
        expect(subject).not_to include(translated(unpublished_voting.title))
        expect(subject).not_to include(translated(external_voting.title))
      end
    end
  end
end
