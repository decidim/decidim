# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Proposal search", type: :request do
  include Decidim::ComponentPathHelper

  subject { response.body }

  let(:component) { create :proposal_component }
  let(:user) { create :user, :confirmed, organization: }
  let(:participatory_space) { component.participatory_space }
  let(:organization) { participatory_space.organization }
  let(:filter_params) { {} }

  let!(:proposal1) { create(:proposal, title: "A doggo", component:) }
  let!(:proposal2) { create(:proposal, body: "There is a doggo in the office", component:) }
  let!(:proposal3) { create(:proposal, component:, users: [user]) }
  let!(:proposal4) { create(:proposal, :withdrawn, component:) }
  let!(:proposal5) { create(:proposal, :rejected, component:) }
  let!(:proposal6) { create(:proposal, :accepted, component:) }
  let!(:proposal7) { create(:proposal, :accepted, component:) }

  let(:meetings_component) { create(:component, manifest_name: "meetings", participatory_space:) }
  let(:meeting) { create :meeting, :published, component: meetings_component }

  let(:dummy_component) { create(:component, manifest_name: "dummy", participatory_space:) }
  let(:dummy_resource) { create :dummy_resource, component: dummy_component }

  let(:request_path) { Decidim::EngineRouter.main_proxy(component).proposals_path }

  before do
    create(:proposal_vote, proposal: proposal1, author: user)

    meeting.link_resources([proposal6], "proposals_from_meeting")
    proposal6.link_resources([meeting], "proposals_from_meeting")
    dummy_resource.link_resources([proposal7], "included_proposals")
    proposal7.link_resources([dummy_resource], "included_proposals")

    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => component.organization.host }
    )
  end

  it_behaves_like "a resource search", :proposal
  it_behaves_like "a resource search with scopes", :proposal
  it_behaves_like "a resource search with categories", :proposal
  it_behaves_like "a resource search with origin", :proposal

  it "displays all non-withdrawn and non-rejected proposals without any filters" do
    expect(subject).to have_escaped_html(translated(proposal1.title))
    expect(subject).to have_escaped_html(translated(proposal2.title))
    expect(subject).to have_escaped_html(translated(proposal3.title))
    expect(subject).not_to have_escaped_html(translated(proposal4.title))
    expect(subject).not_to have_escaped_html(translated(proposal5.title))
    expect(subject).to have_escaped_html(translated(proposal6.title))
    expect(subject).to have_escaped_html(translated(proposal7.title))
  end

  context "when searching by text" do
    let(:filter_params) { { search_text_cont: "doggo" } }

    it "displays only the proposals containing the search_text" do
      expect(subject).to have_escaped_html(translated(proposal1.title))
      expect(subject).to have_escaped_html(translated(proposal2.title))
      expect(subject).not_to have_escaped_html(translated(proposal3.title))
      expect(subject).not_to have_escaped_html(translated(proposal4.title))
      expect(subject).not_to have_escaped_html(translated(proposal5.title))
      expect(subject).not_to have_escaped_html(translated(proposal6.title))
      expect(subject).not_to have_escaped_html(translated(proposal7.title))
    end
  end

  context "when searching by state" do
    let(:filter_params) { { with_any_state: states } }

    context "and the status is empty or default" do
      let(:states) { [] }

      it "displays all except withdrawn proposals" do
        expect(subject).to have_escaped_html(translated(proposal1.title))
        expect(subject).to have_escaped_html(translated(proposal2.title))
        expect(subject).to have_escaped_html(translated(proposal3.title))
        expect(subject).not_to have_escaped_html(translated(proposal4.title))
        expect(subject).to have_escaped_html(translated(proposal5.title))
        expect(subject).to have_escaped_html(translated(proposal6.title))
        expect(subject).to have_escaped_html(translated(proposal7.title))
      end
    end

    context "and the status is accepted, evaluating or state_not_published" do
      let(:states) { %w(accepted evaluating state_not_published) }

      it "does not display withdrawn or rejected proposals" do
        expect(subject).to have_escaped_html(translated(proposal1.title))
        expect(subject).to have_escaped_html(translated(proposal2.title))
        expect(subject).to have_escaped_html(translated(proposal3.title))
        expect(subject).not_to have_escaped_html(translated(proposal4.title))
        expect(subject).not_to have_escaped_html(translated(proposal5.title))
        expect(subject).to have_escaped_html(translated(proposal6.title))
        expect(subject).to have_escaped_html(translated(proposal7.title))
      end
    end

    context "and the status is accepted" do
      let(:states) { %w(accepted) }

      it "displays only accepted proposals" do
        expect(subject).not_to have_escaped_html(translated(proposal1.title))
        expect(subject).not_to have_escaped_html(translated(proposal2.title))
        expect(subject).not_to have_escaped_html(translated(proposal3.title))
        expect(subject).not_to have_escaped_html(translated(proposal4.title))
        expect(subject).not_to have_escaped_html(translated(proposal5.title))
        expect(subject).to have_escaped_html(translated(proposal6.title))
        expect(subject).to have_escaped_html(translated(proposal7.title))
      end
    end

    context "and the status is rejected" do
      let(:states) { %w(rejected) }

      it "displays only rejected proposals" do
        expect(subject).not_to have_escaped_html(translated(proposal1.title))
        expect(subject).not_to have_escaped_html(translated(proposal2.title))
        expect(subject).not_to have_escaped_html(translated(proposal3.title))
        expect(subject).not_to have_escaped_html(translated(proposal4.title))
        expect(subject).to have_escaped_html(translated(proposal5.title))
        expect(subject).not_to have_escaped_html(translated(proposal6.title))
        expect(subject).not_to have_escaped_html(translated(proposal7.title))
      end
    end

    context "and the status is withdrawn" do
      let(:filter_params) { { with_availability: "withdrawn" } }

      it "displays only withdrawn proposals" do
        expect(subject).not_to have_escaped_html(translated(proposal1.title))
        expect(subject).not_to have_escaped_html(translated(proposal2.title))
        expect(subject).not_to have_escaped_html(translated(proposal3.title))
        expect(subject).to have_escaped_html(translated(proposal4.title))
        expect(subject).not_to have_escaped_html(translated(proposal5.title))
        expect(subject).not_to have_escaped_html(translated(proposal6.title))
        expect(subject).not_to have_escaped_html(translated(proposal7.title))
      end
    end
  end

  context "when searching by related to" do
    let(:filter_params) { { related_to: } }

    context "and related to is set to meetings" do
      let(:related_to) { "Decidim::Meetings::Meeting".underscore }

      it "displays only proposals related to meetings" do
        expect(subject).not_to have_escaped_html(translated(proposal1.title))
        expect(subject).not_to have_escaped_html(translated(proposal2.title))
        expect(subject).not_to have_escaped_html(translated(proposal3.title))
        expect(subject).not_to have_escaped_html(translated(proposal4.title))
        expect(subject).not_to have_escaped_html(translated(proposal5.title))
        expect(subject).to have_escaped_html(translated(proposal6.title))
        expect(subject).not_to have_escaped_html(translated(proposal7.title))
      end
    end

    context "and related to is set to resources" do
      let(:related_to) { "Decidim::DummyResources::DummyResource".underscore }

      it "displays only proposals related to resources" do
        expect(subject).not_to have_escaped_html(translated(proposal1.title))
        expect(subject).not_to have_escaped_html(translated(proposal2.title))
        expect(subject).not_to have_escaped_html(translated(proposal3.title))
        expect(subject).not_to have_escaped_html(translated(proposal4.title))
        expect(subject).not_to have_escaped_html(translated(proposal5.title))
        expect(subject).not_to have_escaped_html(translated(proposal6.title))
        expect(subject).to have_escaped_html(translated(proposal7.title))
      end
    end
  end

  context "when searching by activity" do
    let(:filter_params) { { activity: } }

    before do
      login_as user, scope: :user

      get(
        request_path,
        params: { filter: filter_params },
        headers: { "HOST" => component.organization.host }
      )
    end

    context "and the activity is voted" do
      let(:activity) { "voted" }

      it "displays the proposals voted by the user" do
        expect(subject).to have_escaped_html(translated(proposal1.title))
        expect(subject).not_to have_escaped_html(translated(proposal2.title))
        expect(subject).not_to have_escaped_html(translated(proposal3.title))
        expect(subject).not_to have_escaped_html(translated(proposal4.title))
        expect(subject).not_to have_escaped_html(translated(proposal5.title))
        expect(subject).not_to have_escaped_html(translated(proposal6.title))
        expect(subject).not_to have_escaped_html(translated(proposal7.title))
      end
    end

    context "and the activity is my proposals" do
      let(:activity) { "my_proposals" }

      it "displays the proposals created by the user" do
        expect(subject).not_to have_escaped_html(translated(proposal1.title))
        expect(subject).not_to have_escaped_html(translated(proposal2.title))
        expect(subject).to have_escaped_html(translated(proposal3.title))
        expect(subject).not_to have_escaped_html(translated(proposal4.title))
        expect(subject).not_to have_escaped_html(translated(proposal5.title))
        expect(subject).not_to have_escaped_html(translated(proposal6.title))
        expect(subject).not_to have_escaped_html(translated(proposal7.title))
      end
    end
  end
end
