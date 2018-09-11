# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Admin::CreateProject do
    subject { described_class.new(form) }

    let(:organization) { create :organization, available_locales: [:en] }
    let(:current_user) { create :user, :admin, :confirmed, organization: organization }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_component) { create :component, manifest_name: :budgets, participatory_space: participatory_process }
    let(:scope) { create :scope, organization: organization }
    let(:category) { create :category, participatory_space: participatory_process }
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
        category: category,
        current_component: current_component
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
      let(:project) { Project.last }

      it "creates the project" do
        expect { subject.call }.to change(Project, :count).by(1)
      end

      it "sets the scope" do
        subject.call
        expect(project.scope).to eq scope
      end

      it "sets the category" do
        subject.call
        expect(project.category).to eq category
      end

      it "sets the component" do
        subject.call
        expect(project.component).to eq current_component
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
                .with(Project, current_user, hash_including(:scope, :category, :component, :title, :description, :budget))
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
