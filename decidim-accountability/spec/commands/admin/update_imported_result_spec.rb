# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe Admin::UpdateImportedResult do
    subject { described_class.new(form, result) }

    let(:result) { create :result, progress: 10 }
    let(:organization) { result.component.organization }
    let(:user) { create :user, organization: }
    let(:scope) { create :scope, organization: }
    let(:category) { create :category, participatory_space: participatory_process }
    let(:participatory_process) { result.component.participatory_space }
    let(:meeting_component) do
      create(:component, manifest_name: :meetings, participatory_space: participatory_process)
    end

    let(:start_date) { Date.yesterday }
    let(:end_date) { Date.tomorrow }
    let(:status) { create :status, component: result.component, key: "finished", name: { en: "Finished" } }
    let(:progress) { 95 }
    let(:external_id) { "external-id" }
    let(:weight) { 0.3 }

    let(:meeting) do
      create(
        :meeting,
        component: meeting_component
      )
    end
    let(:proposal_component) do
      create(:component, manifest_name: :proposals, participatory_space: participatory_process)
    end
    let(:proposals) do
      create_list(
        :proposal,
        3,
        component: proposal_component
      )
    end
    let(:project_component) do
      create(:component, manifest_name: :budgets, participatory_space: participatory_process)
    end
    let(:projects) do
      create_list(
        :project,
        2,
        component: project_component
      )
    end
    let(:form) do
      double(
        invalid?: invalid,
        title: { en: "title" },
        description: { en: "description" },
        proposal_ids: proposals.map(&:id),
        project_ids: projects.map(&:id),
        scope:,
        category:,
        start_date:,
        end_date:,
        decidim_accountability_status_id: status.id,
        progress:,
        current_user: user,
        parent_id: nil,
        external_id:,
        weight:
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "updates the result" do
        subject.call
        expect(translated(result.title)).to eq "title"
      end

      it "creates a new version for the result", versioning: true do
        expect do
          subject.call
        end.to change { result.versions.count }.by(1)
        expect(result.versions.last.whodunnit).to eq user.to_gid.to_s
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(result, form.current_user, kind_of(Hash))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      it "sets the scope" do
        subject.call
        expect(result.scope).to eq scope
      end

      it "sets the category" do
        subject.call
        expect(result.category).to eq category
      end

      it "links proposals" do
        subject.call
        linked_proposals = result.linked_resources(:proposals, "included_proposals")
        expect(linked_proposals).to match_array(proposals)
      end

      it "links projects" do
        subject.call
        linked_projects = result.linked_resources(:projects, "included_projects")
        expect(linked_projects).to match_array(projects)
      end

      it "links meetings" do
        proposals.each do |proposal|
          proposal.link_resources([meeting], "proposals_from_meeting")
        end

        subject.call
        linked_meetings = result.linked_resources(:meetings, "meetings_through_proposals")

        expect(linked_meetings).to eq [meeting]
      end

      it "sets the external_id" do
        subject.call
        expect(result.external_id).to eq external_id
      end

      it "sets the weight" do
        subject.call
        expect(result.weight).to eq weight
      end

      it "notifies the linked proposals followers" do
        follower = create(:user, organization:)
        create(:follow, followable: proposals.first, user: follower)

        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.accountability.result_progress_updated",
            event_class: Decidim::Accountability::ResultProgressUpdatedEvent,
            resource: result,
            affected_users: [proposals.first.creator_author],
            followers: [follower],
            extra: {
              progress:,
              proposal_id: proposals.first.id
            }
          )

        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.accountability.result_progress_updated",
            event_class: Decidim::Accountability::ResultProgressUpdatedEvent,
            resource: result,
            affected_users: [proposals.second.creator_author],
            followers: [],
            extra: {
              progress:,
              proposal_id: proposals.second.id
            }
          )

        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.accountability.result_progress_updated",
            event_class: Decidim::Accountability::ResultProgressUpdatedEvent,
            resource: result,
            affected_users: [proposals.third.creator_author],
            followers: [],
            extra: {
              progress:,
              proposal_id: proposals.third.id
            }
          )

        subject.call
      end
    end
  end
end
