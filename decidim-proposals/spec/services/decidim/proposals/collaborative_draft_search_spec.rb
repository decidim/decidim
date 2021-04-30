# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe CollaborativeDraftSearch do
      subject { described_class.new(params).results }

      let(:component) { create(:component, manifest_name: "proposals") }
      let(:default_params) { { component: component, user: user } }
      let(:params) { default_params }
      let(:participatory_process) { component.participatory_space }
      let(:user) { create(:user, organization: component.organization) }

      it_behaves_like "a resource search", :collaborative_draft
      it_behaves_like "a resource search with scopes", :collaborative_draft
      it_behaves_like "a resource search with categories", :collaborative_draft

      describe "results" do
        let!(:collaborative_draft) { create(:collaborative_draft, component: component) }

        describe "search_text filter" do
          let(:params) { default_params.merge(search_text: search_text) }
          let(:search_text) { "giraffe" }

          it "returns the drafts containing the search in the title or the body" do
            create_list(:collaborative_draft, 3, component: component)
            create(:collaborative_draft, title: { en: "A giraffe" }, component: component)
            create(:collaborative_draft, body: { en: "There is a giraffe in the office" }, component: component)

            expect(subject.size).to eq(2)
          end
        end

        describe "state filter" do
          let(:params) { default_params.merge(state: states) }

          context "when filtering open collaborative_drafts" do
            let(:states) { %w(open) }

            it "returns only open collaborative_drafts" do
              open_drafts = create_list(:collaborative_draft, 3, :open, component: component)
              create_list(:collaborative_draft, 2, :published, component: component)

              expect(subject.size).to eq(4)
              expect(subject).to match_array([collaborative_draft] + open_drafts)
            end
          end

          context "when filtering withdrawn collaborative_drafts" do
            let(:states) { %w(withdrawn) }

            it "returns only withdrawn collaborative_drafts" do
              create_list(:collaborative_draft, 3, component: component)
              withdrawn_drafts = create_list(:collaborative_draft, 3, :withdrawn, component: component)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(withdrawn_drafts)
            end
          end

          context "when filtering published collaborative_drafts" do
            let(:states) { %w(published) }

            it "returns only published collaborative_drafts" do
              create_list(:collaborative_draft, 3, component: component)
              published_drafts = create_list(:collaborative_draft, 3, :published, component: component)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(published_drafts)
            end
          end
        end

        describe "related_to filter" do
          let(:params) { default_params.merge(related_to: related_to) }

          context "when filtering by related to meetings" do
            let(:related_to) { "Decidim::Meetings::Meeting".underscore }
            let(:meetings_component) { create(:component, manifest_name: "meetings", participatory_space: participatory_process) }
            let(:meeting) { create :meeting, component: meetings_component }

            it "returns only collaborative_drafts related to meetings" do
              related_draft = create(:collaborative_draft, component: component)
              related_draft2 = create(:collaborative_draft, component: component)
              create_list(:collaborative_draft, 3, component: component)
              meeting.link_resources([related_draft], "drafts_from_meeting")
              related_draft2.link_resources([meeting], "drafts_from_meeting")

              expect(subject).to match_array([related_draft, related_draft2])
            end
          end

          context "when filtering by related to resources" do
            let(:related_to) { "Decidim::DummyResources::DummyResource".underscore }
            let(:dummy_component) { create(:component, manifest_name: "dummy", participatory_space: participatory_process) }
            let(:dummy_resource) { create :dummy_resource, component: dummy_component }

            it "returns only collaborative_drafts related to results" do
              related_draft = create(:collaborative_draft, component: component)
              related_draft2 = create(:collaborative_draft, component: component)
              create_list(:collaborative_draft, 3, component: component)
              dummy_resource.link_resources([related_draft], "included_collaborative_drafts")
              related_draft2.link_resources([dummy_resource], "included_collaborative_drafts")

              expect(subject).to match_array([related_draft, related_draft2])
            end
          end
        end
      end
    end
  end
end
