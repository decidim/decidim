# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Admin::ProjectForm do
    subject(:form) { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization, available_locales: [:en]) }
    let(:context) do
      {
        current_organization: organization,
        current_component: current_component,
        current_participatory_space: participatory_process
      }
    end
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_component) { create :budgets_component, participatory_space: participatory_process }
    let(:budget) { create :budget, component: current_component }
    let(:title) do
      Decidim::Faker::Localized.sentence(word_count: 3)
    end
    let(:description) do
      Decidim::Faker::Localized.sentence(word_count: 3)
    end
    let(:budget_amount) { Faker::Number.number(digits: 8) }
    let(:parent_scope) { create(:scope, organization: organization) }
    let(:scope) { create(:subscope, parent: parent_scope) }
    let(:scope_id) { scope.id }
    let(:category) { create :category, participatory_space: participatory_process }
    let(:category_id) { category.id }
    let(:selected) { nil }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
    let(:address) { nil }
    let(:attributes) do
      {
        decidim_scope_id: scope_id,
        decidim_category_id: category_id,
        title_en: title[:en],
        description_en: description[:en],
        budget_amount: budget_amount,
        selected: selected,
        address: address
      }
    end

    it_behaves_like "a scopable resource"

    it { is_expected.to be_valid }

    context "when geocoding is enabled" do
      let(:current_component) { create :budgets_component, :with_geocoding_enabled, participatory_space: participatory_process }

      context "when the address is not present" do
        it "does not store the coordinates" do
          expect(subject).to be_valid
          expect(subject.address).to be_nil
          expect(subject.latitude).to be_nil
          expect(subject.longitude).to be_nil
        end
      end

      context "when the address is present" do
        let(:address) { "Some address" }

        before do
          stub_geocoding(address, [latitude, longitude])
        end

        it "validates the address and store its coordinates" do
          expect(subject).to be_valid
          expect(subject.latitude).to eq(latitude)
          expect(subject.longitude).to eq(longitude)
        end
      end
    end

    describe "when title is missing" do
      let(:title) { { en: nil } }

      it { is_expected.not_to be_valid }
    end

    describe "when description is missing" do
      let(:description) { { en: nil } }

      it { is_expected.not_to be_valid }
    end

    describe "when budget_amount is missing" do
      let(:budget_amount) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when budget_amount is less or equal 0" do
      let(:budget_amount) { 0 }

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

    it "properly maps category id from model" do
      project = create(:project, component: current_component, category: category)

      expect(described_class.from_model(project).decidim_category_id).to eq(category_id)
    end

    context "with proposals" do
      subject { described_class.from_model(project).with_context(context) }

      let(:proposals_component) { create :component, manifest_name: :proposals, participatory_space: participatory_process }
      let!(:proposal) { create :proposal, component: proposals_component }

      let(:project) do
        create(
          :project,
          budget: budget,
          scope: scope,
          category: category
        )
      end

      describe "#proposals" do
        before do
          project.link_resources([proposal], "included_proposals")
        end

        it "returns the available proposals in a way suitable for the form" do
          expect(subject.proposals).to eq([proposal])
        end
      end

      describe "#map_model" do
        subject { described_class.from_model(project).with_context(context) }

        it "sets the proposal_ids correctly" do
          project.link_resources([proposal], "included_proposals")
          expect(subject.proposal_ids).to eq [proposal.id]
        end
      end
    end

    describe "#selected" do
      context "and properly maps selected? from model" do
        let(:project) { create :project, selected_at: selected_at }

        context "when is not selected" do
          let(:selected_at) { nil }

          it { expect(described_class.from_model(project).selected).to be_falsey }
        end

        context "when selected is selected" do
          let(:selected_at) { Time.current }

          it { expect(described_class.from_model(project).selected).to be_truthy }
        end
      end

      context "when is not selected" do
        it { is_expected.to be_valid }
      end

      context "when selected is selected" do
        let(:selected) { true }

        it { is_expected.to be_valid }
      end
    end

    describe "scope" do
      subject { form.scope }

      context "when the scope exists" do
        it { is_expected.to be_kind_of(Decidim::Scope) }
      end

      context "when the scope does not exist" do
        let(:scope_id) { 3456 }

        it { is_expected.to be_nil }
      end

      context "when the scope is from another organization" do
        let(:scope_id) { create(:scope).id }

        it { is_expected.to be_nil }
      end

      context "when the participatory space has a scope" do
        let(:parent_scope) { create(:scope, organization: organization) }
        let(:participatory_process) { create(:participatory_process, :with_steps, organization: organization, scope: parent_scope) }
        let(:scope) { create(:scope, organization: organization, parent: parent_scope) }

        context "when the scope is descendant from participatory space scope" do
          it { is_expected.to eq(scope) }
        end

        context "when the scope is not descendant from participatory space scope" do
          let(:scope) { create(:scope, organization: organization) }

          it { is_expected.to be_valid }

          it "makes the form invalid" do
            expect(form).to be_invalid
          end
        end
      end
    end
  end
end
