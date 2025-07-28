# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Election search" do
  include Decidim::ComponentPathHelper

  subject { response.body }

  let(:component) { create(:elections_component) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:participatory_space) { component.participatory_space }
  let(:organization) { participatory_space.organization }
  let(:filter_params) { {} }

  let!(:unpublished_election) { create(:election, component:) }
  let!(:scheduled_election1) { create(:election, :published, title: { en: "A great election" }, component:) }
  let!(:scheduled_election2) { create(:election, :published, description: { en: "A great description" }, component:) }
  let!(:ongoing_election) { create(:election, :published, :ongoing, component:) }
  let!(:finished_election) { create(:election, :published, :finished, component:) }
  let!(:published_results_election) { create(:election, :published, :published_results, component:) }
  let!(:real_time_election1) { create(:election, :published, :ongoing, :real_time, component:) }
  let!(:real_time_election2) { create(:election, :published, :finished, :real_time, component:) }
  let!(:per_question_election) { create(:election, :published, :ongoing, :per_question, component:) }

  let(:request_path) { Decidim::EngineRouter.main_proxy(component).elections_path }

  before do
    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => component.organization.host }
    )
  end

  it_behaves_like "a resource search", :election
  it "displays all elections without any filters" do
    expect(subject).to include(decidim_escape_translated(scheduled_election1.title))
    expect(subject).to include(decidim_escape_translated(scheduled_election2.title))
    expect(subject).to include(decidim_escape_translated(ongoing_election.title))
    expect(subject).to include(decidim_escape_translated(finished_election.title))
    expect(subject).to include(decidim_escape_translated(published_results_election.title))
    expect(subject).to include(decidim_escape_translated(real_time_election1.title))
    expect(subject).to include(decidim_escape_translated(real_time_election2.title))
    expect(subject).to include(decidim_escape_translated(per_question_election.title))
    expect(subject).not_to include(decidim_escape_translated(unpublished_election.title))
  end

  context "when searching by title text" do
    let(:filter_params) { { search_text_cont: "great election" } }

    before do
      get(
        request_path,
        params: { filter: filter_params },
        headers: { "HOST" => component.organization.host }
      )
    end

    it "returns elections that match the search text" do
      expect(subject).to include(decidim_escape_translated(scheduled_election1.title))
      expect(subject).not_to include(decidim_escape_translated(scheduled_election2.title))
      expect(subject).not_to include(decidim_escape_translated(ongoing_election.title))
      expect(subject).not_to include(decidim_escape_translated(finished_election.title))
      expect(subject).not_to include(decidim_escape_translated(published_results_election.title))
      expect(subject).not_to include(decidim_escape_translated(real_time_election1.title))
      expect(subject).not_to include(decidim_escape_translated(real_time_election2.title))
      expect(subject).not_to include(decidim_escape_translated(per_question_election.title))
    end
  end

  context "when searching by description text" do
    let(:filter_params) { { search_text_cont: "great description" } }

    before do
      get(
        request_path,
        params: { filter: filter_params },
        headers: { "HOST" => component.organization.host }
      )
    end

    it "returns elections that match the search text" do
      expect(subject).not_to include(decidim_escape_translated(scheduled_election1.title))
      expect(subject).to include(decidim_escape_translated(scheduled_election2.title))
      expect(subject).not_to include(decidim_escape_translated(ongoing_election.title))
      expect(subject).not_to include(decidim_escape_translated(finished_election.title))
      expect(subject).not_to include(decidim_escape_translated(published_results_election.title))
      expect(subject).not_to include(decidim_escape_translated(real_time_election1.title))
      expect(subject).not_to include(decidim_escape_translated(real_time_election2.title))
      expect(subject).not_to include(decidim_escape_translated(per_question_election.title))
    end
  end

  context "when searching by state" do
    let(:filter_params) { { with_any_state: state } }
    let(:state) { ["scheduled"] }

    before do
      get(
        request_path,
        params: { filter: filter_params },
        headers: { "HOST" => component.organization.host }
      )
    end

    it "only returns elections that are scheduled" do
      expect(subject).to include(decidim_escape_translated(scheduled_election1.title))
      expect(subject).to include(decidim_escape_translated(scheduled_election2.title))
      expect(subject).not_to include(decidim_escape_translated(ongoing_election.title))
      expect(subject).not_to include(decidim_escape_translated(finished_election.title))
      expect(subject).not_to include(decidim_escape_translated(published_results_election.title))
      expect(subject).not_to include(decidim_escape_translated(real_time_election1.title))
      expect(subject).not_to include(decidim_escape_translated(real_time_election2.title))
      expect(subject).not_to include(decidim_escape_translated(per_question_election.title))
    end

    context "when state is ongoing" do
      let(:state) { ["ongoing"] }

      it "only returns elections that are ongoing" do
        expect(subject).not_to include(decidim_escape_translated(scheduled_election1.title))
        expect(subject).not_to include(decidim_escape_translated(scheduled_election2.title))
        expect(subject).to include(decidim_escape_translated(ongoing_election.title))
        expect(subject).not_to include(decidim_escape_translated(finished_election.title))
        expect(subject).not_to include(decidim_escape_translated(published_results_election.title))
        expect(subject).to include(decidim_escape_translated(real_time_election1.title))
        expect(subject).not_to include(decidim_escape_translated(real_time_election2.title))
        expect(subject).to include(decidim_escape_translated(per_question_election.title))
      end
    end

    context "when state is finished" do
      let(:state) { ["finished"] }

      it "only returns elections that are finished" do
        expect(subject).not_to include(decidim_escape_translated(scheduled_election1.title))
        expect(subject).not_to include(decidim_escape_translated(scheduled_election2.title))
        expect(subject).not_to include(decidim_escape_translated(ongoing_election.title))
        expect(subject).to include(decidim_escape_translated(finished_election.title))
        expect(subject).to include(decidim_escape_translated(published_results_election.title))
        expect(subject).not_to include(decidim_escape_translated(real_time_election1.title))
        expect(subject).to include(decidim_escape_translated(real_time_election2.title))
        expect(subject).not_to include(decidim_escape_translated(per_question_election.title))
      end
    end
  end

  describe "#index" do
    let(:url) { "http://#{component.organization.host + request_path}" }

    it "redirects to the index page" do
      get(
        url_to_root(request_path),
        params: {},
        headers: { "HOST" => component.organization.host }
      )
      expect(response["Location"]).to eq(url)
      expect(response).to have_http_status(:moved_permanently)
    end
  end

  private

  def url_to_root(url)
    parts = url.split("/")
    parts[0..-2].join("/")
  end
end
