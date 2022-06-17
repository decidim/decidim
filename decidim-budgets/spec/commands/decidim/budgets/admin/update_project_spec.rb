# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Admin::UpdateProject do
    subject { described_class.new(form, project) }

    let(:budget) { create :budget }
    let(:project) { create :project, budget: }
    let(:organization) { budget.component.organization }
    let(:scope) { create :scope, organization: }
    let(:category) { create :category, participatory_space: budget.component.participatory_space }
    let(:participatory_process) { budget.component.participatory_space }
    let(:current_user) { create :user, :admin, :confirmed, organization: }
    let(:uploaded_photos) { [] }
    let(:selected) { nil }
    let(:current_photos) { [] }
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
        current_user:,
        title: { en: "title" },
        description: { en: "description" },
        budget_amount: 10_000_000,
        proposal_ids: proposals.map(&:id),
        scope:,
        category:,
        selected:,
        photos: current_photos,
        add_photos: uploaded_photos
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
          .with(
            project,
            current_user,
            hash_including(:scope, :category, :title, :description, :budget_amount)
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

      it_behaves_like "admin manages resource gallery" do
        let!(:resource) { project }
        let(:resource_class) { Decidim::Budgets::Project }
        let(:command) { described_class.new(form, resource) }
      end

      context "when project is selected" do
        let(:selected) { true }

        it "saves a timestamp" do
          subject.call

          expect(project.selected_at).to be_present
          expect(project.selected_at).to be_kind_of(Date)
          expect(project.selected?).to be true
        end
      end
    end
  end
end
