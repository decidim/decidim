# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Admin::CreateProject do
  let(:organization) { create :organization, available_locales: [:en] }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_feature) { create :feature, manifest_name: :budgets, participatory_process: participatory_process }
  let(:scope) { create :scope, organization: organization }
  let(:category) { create :category, participatory_process: participatory_process }
  let(:proposal_feature) do
    create(:feature, manifest_name: :proposals, participatory_process: participatory_process)
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
      title: { en: "title" },
      description: { en: "description" },
      budget: 10_000_000,
      proposal_ids: proposals.map(&:id),
      scope: scope,
      category: category,
      current_feature: current_feature
    )
  end
  let(:invalid) { false }

  subject { described_class.new(form) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    let(:project) { Decidim::Budgets::Project.last }

    it "creates the project" do
      expect { subject.call }.to change { Decidim::Budgets::Project.count }.by(1)
    end

    it "sets the scope" do
      subject.call
      expect(project.scope).to eq scope
    end

    it "sets the category" do
      subject.call
      expect(project.category).to eq category
    end

    it "sets the feature" do
      subject.call
      expect(project.feature).to eq current_feature
    end

    it "links proposals" do
      subject.call
      linked_proposals = project.linked_resources(:proposals, "included_proposals")
      expect(linked_proposals).to match_array(proposals)
    end
  end
end
