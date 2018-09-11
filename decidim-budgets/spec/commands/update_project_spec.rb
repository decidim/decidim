# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Admin::UpdateProject do
    subject { described_class.new(form, project) }

    let(:project) { create :project }
    let(:organization) { project.component.organization }
    let(:scope) { create :scope, organization: organization }
    let(:category) { create :category, participatory_space: project.component.participatory_space }
    let(:participatory_process) { project.component.participatory_space }
    let(:current_user) { create :user, :admin, :confirmed, organization: organization }
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
    let(:address) { "address" }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
    let(:form) do
      double(
        invalid?: invalid,
        current_user: current_user,
        title: { en: "title" },
        description: { en: "description" },
        budget: 10_000_000,
        address: address,
        latitude: latitude,
        longitude: longitude,
        proposal_ids: proposals.map(&:id),
        scope: scope,
        category: category
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
      it "updates the project" do
        subject.call
        expect(translated(project.title)).to eq "title"
      end

      it "sets the scope" do
        subject.call
        expect(project.scope).to eq scope
      end

      it "sets the category" do
        subject.call
        expect(project.category).to eq category
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(project, current_user, hash_including(:scope, :category, :title, :description, :budget))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      it "links proposals" do
        subject.call
        linked_proposals = project.linked_resources(:proposals, "included_proposals")
        expect(linked_proposals).to match_array(proposals)
      end
    end
  end
end
