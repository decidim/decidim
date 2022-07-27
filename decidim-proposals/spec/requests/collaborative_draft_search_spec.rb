# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Collaborative draft search", type: :request do
  include Decidim::ComponentPathHelper

  subject { response.body }

  let(:component) do
    create(
      :proposal_component,
      :with_creation_enabled,
      settings: { collaborative_drafts_enabled: true }
    )
  end
  let(:user) { create :user, :confirmed, organization: }
  let(:participatory_space) { component.participatory_space }
  let(:organization) { participatory_space.organization }
  let(:filter_params) { {} }

  let!(:collaborative_draft1) { create(:collaborative_draft, title: { en: "A doggo" }, component:) }
  let!(:collaborative_draft2) { create(:collaborative_draft, body: { en: "There is a doggo in the office" }, component:) }
  let!(:collaborative_draft3) { create(:collaborative_draft, :open, component:) }
  let!(:collaborative_draft4) { create(:collaborative_draft, :published, component:) }
  let!(:collaborative_draft5) { create(:collaborative_draft, :withdrawn, component:) }
  let!(:collaborative_draft6) { create(:collaborative_draft, component:) }
  let!(:collaborative_draft7) { create(:collaborative_draft, component:) }

  let(:meetings_component) { create(:component, manifest_name: "meetings", participatory_space:) }
  let(:meeting) { create :meeting, :published, component: meetings_component }

  let(:dummy_component) { create(:component, manifest_name: "dummy", participatory_space:) }
  let(:dummy_resource) { create :dummy_resource, component: dummy_component }

  let(:request_path) { Decidim::EngineRouter.main_proxy(component).collaborative_drafts_path }

  before do
    meeting.link_resources([collaborative_draft6], "drafts_from_meeting")
    collaborative_draft6.link_resources([meeting], "drafts_from_meeting")
    dummy_resource.link_resources([collaborative_draft7], "included_collaborative_drafts")
    collaborative_draft7.link_resources([dummy_resource], "included_collaborative_drafts")

    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => component.organization.host }
    )
  end

  it_behaves_like "a resource search", :collaborative_draft
  it_behaves_like "a resource search with scopes", :collaborative_draft
  it_behaves_like "a resource search with categories", :collaborative_draft

  it "displays all collaborative drafts except published and withdrawn without any filters" do
    expect(subject).to have_escaped_html(translated(collaborative_draft1.title))
    expect(subject).to have_escaped_html(translated(collaborative_draft2.title))
    expect(subject).to have_escaped_html(translated(collaborative_draft3.title))
    expect(subject).not_to have_escaped_html(translated(collaborative_draft4.title))
    expect(subject).not_to have_escaped_html(translated(collaborative_draft5.title))
    expect(subject).to have_escaped_html(translated(collaborative_draft6.title))
    expect(subject).to have_escaped_html(translated(collaborative_draft7.title))
  end

  context "when searching by text" do
    let(:filter_params) { { search_text_cont: "doggo" } }

    it "displays only the collaborative drafts containing the search_text" do
      expect(subject).to have_escaped_html(translated(collaborative_draft1.title))
      expect(subject).to have_escaped_html(translated(collaborative_draft2.title))
      expect(subject).not_to have_escaped_html(translated(collaborative_draft3.title))
      expect(subject).not_to have_escaped_html(translated(collaborative_draft4.title))
      expect(subject).not_to have_escaped_html(translated(collaborative_draft5.title))
      expect(subject).not_to have_escaped_html(translated(collaborative_draft6.title))
      expect(subject).not_to have_escaped_html(translated(collaborative_draft7.title))
    end
  end

  context "when searching by state" do
    let(:filter_params) { { with_any_state: states } }

    context "and the status is open" do
      let(:states) { %w(open) }

      it "displays only open collaborative drafts" do
        expect(subject).to have_escaped_html(translated(collaborative_draft1.title))
        expect(subject).to have_escaped_html(translated(collaborative_draft2.title))
        expect(subject).to have_escaped_html(translated(collaborative_draft3.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft4.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft5.title))
        expect(subject).to have_escaped_html(translated(collaborative_draft6.title))
        expect(subject).to have_escaped_html(translated(collaborative_draft7.title))
      end
    end

    context "and the status is withdrawn" do
      let(:states) { %w(withdrawn) }

      it "displays only withdrawn collaborative drafts" do
        expect(subject).not_to have_escaped_html(translated(collaborative_draft1.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft2.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft3.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft4.title))
        expect(subject).to have_escaped_html(translated(collaborative_draft5.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft6.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft7.title))
      end
    end

    context "and the status is published" do
      let(:states) { %w(published) }

      it "displays only withdrawn proposals" do
        expect(subject).not_to have_escaped_html(translated(collaborative_draft1.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft2.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft3.title))
        expect(subject).to have_escaped_html(translated(collaborative_draft4.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft5.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft6.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft7.title))
      end
    end
  end

  context "when searching by related to" do
    let(:filter_params) { { related_to: } }

    context "and related to is set to meetings" do
      let(:related_to) { "Decidim::Meetings::Meeting".underscore }

      it "displays only proposals related to meetings" do
        expect(subject).not_to have_escaped_html(translated(collaborative_draft1.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft2.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft3.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft4.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft5.title))
        expect(subject).to have_escaped_html(translated(collaborative_draft6.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft7.title))
      end
    end

    context "and related to is set to resources" do
      let(:related_to) { "Decidim::DummyResources::DummyResource".underscore }

      it "displays only proposals related to resources" do
        expect(subject).not_to have_escaped_html(translated(collaborative_draft1.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft2.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft3.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft4.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft5.title))
        expect(subject).not_to have_escaped_html(translated(collaborative_draft6.title))
        expect(subject).to have_escaped_html(translated(collaborative_draft7.title))
      end
    end
  end
end
