# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::DebateForm do
  subject(:form) { described_class.from_params(attributes).with_context(context) }

  let(:organization) { create(:organization) }
  let(:context) do
    {
      current_organization: organization,
      current_component:,
      current_participatory_space: participatory_process
    }
  end
  let(:participatory_process) { create :participatory_process, organization: }
  let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "debates" }
  let(:title) { "My title" }
  let(:description) { "My description" }
  let(:category) { create :category, participatory_space: participatory_process }
  let(:category_id) { category.id }
  let(:parent_scope) { create(:scope, organization:) }
  let(:scope) { create(:subscope, parent: parent_scope) }
  let(:scope_id) { scope.id }
  let(:attributes) do
    {
      category_id:,
      scope_id:,
      title:,
      description:
    }
  end

  it_behaves_like "a scopable resource"

  it { is_expected.to be_valid }

  describe "when title is missing" do
    let(:title) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when description is missing" do
    let(:description) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when the category does not exist" do
    let(:category_id) { category.id + 10 }

    it { is_expected.not_to be_valid }
  end

  context "when a debate exists" do
    subject { described_class.from_model(debate).with_context(context.merge(current_user: user)) }

    let(:debate) { create :debate, category:, component: current_component }

    describe "when the user is the author" do
      let(:user) { debate.author }

      it { is_expected.to be_valid }
    end

    describe "when the user is not the author" do
      let(:user) { create(:user, organization:) }

      it { is_expected.not_to be_valid }
    end
  end

  describe "map_model" do
    subject { described_class.from_model(debate).with_context(context) }

    let(:debate) { create :debate, category:, component: current_component }

    it "sets the title" do
      expect(subject.title).to be_present
    end

    it "sets the description" do
      expect(subject.description).to be_present
    end

    it "sets the category" do
      expect(subject.category).to be_present
    end

    it "sets the debate" do
      expect(subject.debate).to eq(debate)
    end
  end
end
