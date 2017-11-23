# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe Admin::CreateResult do
    subject { described_class.new(form) }

    let(:organization) { create :organization, available_locales: [:en] }
    let(:user) { create :user, organization: organization }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_feature) { create :accountability_feature, participatory_space: participatory_process }
    let(:scope) { create :scope, organization: organization }
    let(:category) { create :category, participatory_space: participatory_process }

    let(:start_date) { Date.yesterday }
    let(:end_date) { Date.tomorrow }
    let(:status) { create :status, feature: current_feature, key: "ongoing", name: { en: "Ongoing" } }
    let(:progress) { 89 }

    let(:meeting_feature) do
      create(:feature, manifest_name: "meetings", participatory_space: participatory_process)
    end
    let(:meeting) do
      create(
        :meeting,
        feature: meeting_feature
      )
    end
    let(:proposal_feature) do
      create(:feature, manifest_name: "proposals", participatory_space: participatory_process)
    end
    let(:proposals) do
      create_list(
        :proposal,
        3,
        feature: proposal_feature
      )
    end
    let(:form) do
      double(
        invalid?: invalid,
        current_feature: current_feature,
        title: { en: "title" },
        description: { en: "description" },
        proposal_ids: proposals.map(&:id),
        scope: scope,
        category: category,
        start_date: start_date,
        end_date: end_date,
        decidim_accountability_status_id: status.id,
        progress: progress,
        current_user: user,
        parent_id: nil
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
        expect { subject.call }.to change { Result.count }.by(1)
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

      it "sets the feature" do
        subject.call
        expect(result.feature).to eq current_feature
      end

      it "links proposals" do
        subject.call
        linked_proposals = result.linked_resources(:proposals, "included_proposals")
        expect(linked_proposals).to match_array(proposals)
      end

      it "links meetings" do
        proposals.each do |proposal|
          proposal.link_resources([meeting], "proposals_from_meeting")
        end

        subject.call
        linked_meetings = result.linked_resources(:meetings, "meetings_through_proposals")

        expect(linked_meetings).to eq [meeting]
      end
    end
  end
end
