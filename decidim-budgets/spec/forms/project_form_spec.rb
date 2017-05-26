# frozen_string_literal: true

# frozen_literal_string: true

require "spec_helper"

describe Decidim::Budgets::Admin::ProjectForm do
  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:context) do
    {
      current_organization: organization,
      current_feature: current_feature
    }
  end
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_feature) { create :budget_feature, participatory_process: participatory_process }
  let(:title) do
    Decidim::Faker::Localized.sentence(3)
  end
  let(:description) do
    Decidim::Faker::Localized.sentence(3)
  end
  let(:budget) { Faker::Number.number(8) }
  let(:scope) { create :scope, organization: organization }
  let(:scope_id) { scope.id }
  let(:category) { create :category, participatory_process: participatory_process }
  let(:category_id) { category.id }
  let(:attributes) do
    {
      decidim_scope_id: scope_id,
      decidim_category_id: category_id,
      title_en: title[:en],
      description_en: description[:en],
      budget: budget
    }
  end

  subject { described_class.from_params(attributes).with_context(context) }

  it { is_expected.to be_valid }

  describe "when title is missing" do
    let(:title) { { en: nil } }

    it { is_expected.not_to be_valid }
  end

  describe "when description is missing" do
    let(:description) { { en: nil } }

    it { is_expected.not_to be_valid }
  end

  describe "when budget is missing" do
    let(:budget) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when budget is less or equal 0" do
    let(:budget) { 0 }

    it { is_expected.not_to be_valid }
  end

  describe "when the scope does not exist" do
    let(:scope_id) { scope.id + 10 }

    it { is_expected.not_to be_valid }
  end

  describe "when the category does not exist" do
    let(:category_id) { category.id + 10 }

    it { is_expected.not_to be_valid }
  end

  context "with proposals" do
    let(:proposals_feature) { create :feature, manifest_name: :proposals, participatory_process: participatory_process }
    let!(:proposal) { create :proposal, feature: proposals_feature }

    describe "#proposals" do
      it "returns the available proposals in a way suitable for the form" do
        expect(subject.proposals)
          .to eq([[proposal.title, proposal.id]])
      end
    end

    describe "#map_model" do
      let(:project) do
        create(
          :project,
          feature: current_feature,
          scope: scope,
          category: category
        )
      end

      subject { described_class.from_model(project).with_context(context) }

      it "sets the proposal_ids correctly" do
        project.link_resources([proposal], "included_proposals")
        expect(subject.proposal_ids).to eq [proposal.id]
      end
    end
  end
end
