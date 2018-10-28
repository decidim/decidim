# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe CollaborativeDraftSearch do
      let(:component) { create(:component, manifest_name: "proposals") }
      let(:scope1) { create :scope, organization: component.organization }
      let(:scope2) { create :scope, organization: component.organization }
      let(:subscope1) { create :scope, organization: component.organization, parent: scope1 }
      let(:participatory_process) { component.participatory_space }
      let(:user) { create(:user, organization: component.organization) }
      let!(:collaborative_draft) { create(:collaborative_draft, component: component, scope: scope1) }

      describe "results" do
        subject do
          described_class.new(
            component: component,
            search_text: search_text,
            state: state,
            related_to: related_to,
            scope_id: scope_id,
            # current_user: user
          ).results
        end

        let(:search_text) { nil }
        let(:related_to) { nil }
        let(:state) { "open" }
        let(:scope_id) { nil }

        it "only includes drafts from the given component" do
          other_draft = create(:collaborative_draft)

          expect(subject).to include(collaborative_draft)
          expect(subject).not_to include(other_draft)
        end

        describe "search_text filter" do
          let(:search_text) { "giraffe" }

          it "returns the drafts containing the search in the title or the body" do
            create_list(:collaborative_draft, 3, component: component)
            create(:collaborative_draft, title: "A giraffe", component: component)
            create(:collaborative_draft, body: "There is a giraffe in the office", component: component)

            expect(subject.size).to eq(2)
          end
        end

        describe "state filter" do
          context "when filtering open collaborative_drafts" do
            let(:state) { "open" }

            it "returns only open collaborative_drafts" do
              open_drafts = create_list(:collaborative_draft, 3, :open, component: component)
              create_list(:collaborative_draft, 2, :published, component: component)

              expect(subject.size).to eq(4)
              expect(subject).to match_array([collaborative_draft] + open_drafts)
            end
          end

          context "when filtering withdrawn collaborative_drafts" do
            let(:state) { "withdrawn" }

            it "returns only withdrawn collaborative_drafts" do
              create_list(:collaborative_draft, 3, component: component)
              withdrawn_drafts = create_list(:collaborative_draft, 3, :withdrawn, component: component)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(withdrawn_drafts)
            end
          end

          context "when filtering published collaborative_drafts" do
            let(:state) { "published" }

            it "returns only published collaborative_drafts" do
              create_list(:collaborative_draft, 3, component: component)
              published_drafts = create_list(:collaborative_draft, 3, :published, component: component)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(published_drafts)
            end
          end
        end

        describe "scope_id filter" do
          let!(:draft2) { create(:collaborative_draft, component: component, scope: scope2) }
          let!(:draft3) { create(:collaborative_draft, component: component, scope: subscope1) }

          context "when a parent scope id is being sent" do
            let(:scope_id) { scope1.id }

            it "filters collaborative_drafts by scope" do
              expect(subject).to match_array [collaborative_draft, draft3]
            end
          end

          context "when a subscope id is being sent" do
            let(:scope_id) { subscope1.id }

            it "filters collaborative_drafts by scope" do
              expect(subject).to eq [draft3]
            end
          end

          context "when multiple ids are sent" do
            let(:scope_id) { [scope2.id, scope1.id] }

            it "filters collaborative_drafts by scope" do
              expect(subject).to match_array [collaborative_draft, draft2, draft3]
            end
          end

          context "when `global` is being sent" do
            let!(:resource_without_scope) { create(:collaborative_draft, component: component, scope: nil) }
            let(:scope_id) { ["global"] }

            it "returns collaborative_draft without a scope" do
              expect(subject).to eq [resource_without_scope]
            end
          end

          context "when `global` and some ids is being sent" do
            let!(:resource_without_scope) { create(:collaborative_draft, component: component, scope: nil) }
            let(:scope_id) { ["global", scope2.id, scope1.id] }

            it "returns collaborative_drafts without a scope and with selected scopes" do
              expect(subject).to match_array [resource_without_scope, collaborative_draft, draft2, draft3]
            end
          end
        end

        describe "related_to filter" do
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
