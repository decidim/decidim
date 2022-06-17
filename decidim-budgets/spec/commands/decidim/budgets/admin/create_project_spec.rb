# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Admin::CreateProject do
    subject { described_class.new(form) }

    let(:organization) { create :organization, available_locales: [:en] }
    let(:current_user) { create :user, :admin, :confirmed, organization: }
    let(:participatory_process) { create :participatory_process, organization: }
    let(:current_component) { create :component, manifest_name: :budgets, participatory_space: participatory_process }
    let(:budget) { create :budget, component: current_component }
    let(:scope) { create :scope, organization: }
    let(:category) { create :category, participatory_space: participatory_process }
    let(:uploaded_photos) { [] }
    let(:photos) { [] }
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
    let(:form) do
      double(
        invalid?: invalid,
        current_component:,
        current_user:,
        title: { en: "title" },
        description: { en: "description" },
        budget_amount: 10_000_000,
        proposal_ids: proposals.map(&:id),
        scope:,
        category:,
        photos:,
        add_photos: uploaded_photos,
        budget:
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

      it "sets the budget resource" do
        subject.call
        expect(project.budget).to eq budget
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(
            Decidim::Budgets::Project,
            current_user,
            hash_including(:scope, :category, :budget, :title, :description, :budget_amount),
            visibility: "all"
          )
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

      it_behaves_like "admin creates resource gallery" do
        let(:command) { described_class.new(form) }
        let(:resource_class) { Decidim::Budgets::Project }
      end
    end
  end
end
