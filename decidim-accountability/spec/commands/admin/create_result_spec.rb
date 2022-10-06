# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe Admin::CreateResult do
    subject { described_class.new(form) }

    let(:organization) { create :organization, available_locales: [:en] }
    let(:user) { create :user, organization: }
    let(:participatory_process) { create :participatory_process, organization: }
    let(:current_component) { create :accountability_component, participatory_space: participatory_process }
    let(:scope) { create :scope, organization: }
    let(:category) { create :category, participatory_space: participatory_process }

    let(:start_date) { Date.yesterday }
    let(:end_date) { Date.tomorrow }
    let(:status) { create :status, component: current_component, key: "ongoing", name: { en: "Ongoing" } }
    let(:progress) { 89 }
    let(:external_id) { "external-id" }
    let(:weight) { 0.3 }

    let(:meeting_component) do
      create(:component, manifest_name: "meetings", participatory_space: participatory_process)
    end
    let(:meeting) do
      create(
        :meeting,
        component: meeting_component
      )
    end
    let(:proposal_component) do
      create(:component, manifest_name: "proposals", participatory_space: participatory_process)
    end
    let(:proposals) do
      create_list(
        :proposal,
        3,
        component: proposal_component
      )
    end
    let(:project_component) do
      create(:component, manifest_name: "budgets", participatory_space: participatory_process)
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
        current_component:,
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
      let(:result) { Result.last }

      it "creates the result" do
        expect { subject.call }.to change(Result, :count).by(1)
      end

      it "sets the scope" do
        subject.call
        expect(result.scope).to eq scope
      end

      it "creates a new version for the result", versioning: true do
        subject.call
        expect(result.versions.count).to eq 1
        expect(result.versions.last.whodunnit).to eq user.to_gid.to_s
      end

      it "sets the category" do
        subject.call
        expect(result.category).to eq category
      end

      it "sets the component" do
        subject.call
        expect(result.component).to eq current_component
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

      it "notifies the linked proposals followers" do
        follower = create(:user, organization:)
        create(:follow, followable: proposals.first, user: follower)

        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.accountability.proposal_linked",
            event_class: Decidim::Accountability::ProposalLinkedEvent,
            resource: kind_of(Result),
            affected_users: [proposals.first.creator_author],
            followers: [follower],
            extra: {
              proposal_id: proposals.first.id
            }
          )

        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.accountability.proposal_linked",
            event_class: Decidim::Accountability::ProposalLinkedEvent,
            resource: kind_of(Result),
            affected_users: [proposals.second.creator_author],
            followers: [],
            extra: {
              proposal_id: proposals.second.id
            }
          )

        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.accountability.proposal_linked",
            event_class: Decidim::Accountability::ProposalLinkedEvent,
            resource: kind_of(Result),
            affected_users: [proposals.third.creator_author],
            followers: [],
            extra: {
              proposal_id: proposals.third.id
            }
          )

        subject.call
      end

      it "sets the external_id" do
        subject.call
        expect(result.external_id).to eq external_id
      end

      it "sets the weight" do
        subject.call
        expect(result.weight).to eq weight
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(Result, user, kind_of(Hash), visibility: "all")
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
