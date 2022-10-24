# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Sortition search", type: :request do
  include Decidim::ComponentPathHelper

  subject { response.body }

  let(:component) { create :sortition_component }
  let(:participatory_space) { component.participatory_space }
  let(:organization) { participatory_space.organization }
  let(:filter_params) { {} }

  let!(:sortition1) { create(:sortition, title: { en: "A doggo" }, component:) }
  let!(:sortition2) { create(:sortition, additional_info: { en: "There is a doggo in the office" }, component:) }
  let!(:sortition3) { create(:sortition, witnesses: { en: "My doggo was there" }, component:) }
  let!(:sortition4) { create(:sortition, component:) }
  let!(:sortition5) { create(:sortition, :cancelled, component:) }

  let(:request_path) { Decidim::EngineRouter.main_proxy(component).sortitions_path }

  before do
    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => component.organization.host }
    )
  end

  it_behaves_like "a resource search", :sortition
  it_behaves_like "a resource search with categories", :sortition, :single

  it "displays all non-cancelled sortitions without any filters" do
    expect(subject).to include(translated(sortition1.title))
    expect(subject).to include(translated(sortition2.title))
    expect(subject).to include(translated(sortition3.title))
    expect(subject).to include(translated(sortition4.title))
    expect(subject).not_to include(translated(sortition5.title))
  end

  context "when searching by text" do
    let(:filter_params) { { search_text_cont: "doggo" } }

    it "displays only the sortitions containing the search_text" do
      expect(subject).to include(translated(sortition1.title))
      expect(subject).to include(translated(sortition2.title))
      expect(subject).to include(translated(sortition3.title))
      expect(subject).not_to include(translated(sortition4.title))
      expect(subject).not_to include(translated(sortition5.title))
    end
  end

  context "when searching by state" do
    let(:filter_params) { { with_any_state: state } }

    context "and the state is active" do
      let(:state) { "active" }

      it "displays the active sortitions" do
        expect(subject).to include(translated(sortition1.title))
        expect(subject).to include(translated(sortition2.title))
        expect(subject).to include(translated(sortition3.title))
        expect(subject).to include(translated(sortition4.title))
        expect(subject).not_to include(translated(sortition5.title))
      end
    end

    context "and the state is cancelled" do
      let(:state) { "cancelled" }

      it "displays only the cancelled sortition" do
        expect(subject).not_to include(translated(sortition1.title))
        expect(subject).not_to include(translated(sortition2.title))
        expect(subject).not_to include(translated(sortition3.title))
        expect(subject).not_to include(translated(sortition4.title))
        expect(subject).to include(translated(sortition5.title))
      end
    end

    context "and the state is all" do
      let(:state) { "all" }

      it "displays all the sortitions" do
        expect(subject).to include(translated(sortition1.title))
        expect(subject).to include(translated(sortition2.title))
        expect(subject).to include(translated(sortition3.title))
        expect(subject).to include(translated(sortition4.title))
        expect(subject).to include(translated(sortition5.title))
      end
    end
  end
end
