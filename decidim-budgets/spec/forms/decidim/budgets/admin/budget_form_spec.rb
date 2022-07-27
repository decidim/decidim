# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Admin::BudgetForm do
  subject { described_class.from_params(attributes).with_context(context) }

  let(:organization) { create(:organization) }
  let(:context) do
    {
      current_organization: organization,
      current_component:
    }
  end
  let(:participatory_process) { create :participatory_process, organization: }
  let(:current_component) { create :budgets_component, participatory_space: participatory_process }
  let(:scope) { create :scope, organization: }
  let(:scope_id) { scope.id }
  let(:title) { Decidim::Faker::Localized.sentence(word_count: 3) }
  let(:description) { Decidim::Faker::Localized.sentence(word_count: 3) }
  let(:weight) { 1 }
  let(:total_budget) { 100_000_000 }

  let(:attributes) do
    {
      title:,
      description:,
      weight:,
      total_budget:,
      decidim_scope_id: scope_id
    }
  end

  it { is_expected.to be_valid }

  describe "when title is missing" do
    let(:title) { { ca: nil, es: nil } }

    it { is_expected.not_to be_valid }
  end

  describe "when weight is missing" do
    let(:weight) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when total_budget is missing" do
    let(:total_budget) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when the scope does not exist" do
    let(:scope_id) { scope.id + 10 }

    it { is_expected.not_to be_valid }
  end
end
