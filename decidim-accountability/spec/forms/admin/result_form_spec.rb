# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe Admin::ResultForm do
    subject(:form) { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization, available_locales: [:en]) }
    let(:context) do
      {
        current_organization: organization,
        current_feature: current_feature
      }
    end
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_feature) { create :accountability_feature, participatory_space: participatory_process }
    let(:title) do
      Decidim::Faker::Localized.sentence(3)
    end
    let(:description) do
      Decidim::Faker::Localized.sentence(3)
    end
    let(:scope) { create :scope, organization: organization }
    let(:scope_id) { scope.id }
    let(:category) { create :category, participatory_space: participatory_process }
    let(:category_id) { category.id }
    let(:parent) { create :result, scope: scope, feature: current_feature }
    let(:parent_id) { parent.id }
    let(:start_date) { "12/3/2017" }
    let(:end_date) { "21/6/2017" }
    let(:status) { create :status, feature: current_feature, key: "ongoing", name: { en: "Ongoing" } }
    let(:status_id) { status.id }
    let(:progress) { 89 }

    let(:attributes) do
      {
        decidim_scope_id: scope_id,
        decidim_category_id: category_id,
        parent_id: parent_id,
        title_en: title[:en],
        description_en: description[:en],
        start_date: start_date,
        end_date: end_date,
        decidim_accountability_status_id: status_id,
        progress: progress
      }
    end

    it { is_expected.to be_valid }

    describe "when title is missing" do
      let(:title) { { en: nil } }

      it { is_expected.not_to be_valid }
    end

    describe "when description is missing" do
      let(:description) { { en: nil } }

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

    describe "when the parent does not exist" do
      let(:parent_id) { parent.id + 10 }

      it { is_expected.not_to be_valid }
    end

    describe "when the status does not exist" do
      let(:status_id) { status.id + 10 }

      it { is_expected.not_to be_valid }
    end

    context "with proposals" do
      let(:proposals_feature) { create :feature, manifest_name: :proposals, participatory_space: participatory_process }
      let!(:proposal) { create :proposal, feature: proposals_feature }

      describe "#proposals" do
        it "returns the available proposals in a way suitable for the form" do
          expect(subject.proposals)
            .to eq([[proposal.title, proposal.id]])
        end
      end

      describe "#map_model" do
        subject { described_class.from_model(result).with_context(context) }

        let(:result) do
          create(
            :result,
            feature: current_feature,
            scope: scope,
            category: category
          )
        end

        it "sets the proposal_ids correctly" do
          result.link_resources([proposal], "included_proposals")
          expect(subject.proposal_ids).to eq [proposal.id]
          expect(subject.decidim_category_id).to eq category.id
        end
      end
    end

    describe "scope" do
      subject { form.scope }

      context "when the scope exists" do
        it { is_expected.to be_kind_of(Decidim::Scope) }
      end

      context "when the scope does not exist" do
        let(:scope_id) { 3456 }

        it { is_expected.to eq(nil) }
      end

      context "when the scope is from another organization" do
        let(:scope_id) { create(:scope).id }

        it { is_expected.to eq(nil) }
      end

      context "when the participatory space has a scope" do
        let(:parent_scope) { create(:scope, organization: organization) }
        let(:participatory_process) { create :participatory_process, organization: organization, scope: parent_scope }
        let(:scope) { create(:scope, organization: organization, parent: parent_scope) }

        context "when the scope is descendant from participatory space scope" do
          it { is_expected.to eq(scope) }
        end

        context "when the scope is not descendant from participatory space scope" do
          let(:scope) { create(:scope, organization: organization) }

          it { is_expected.to eq(scope) }

          it "makes the form invalid" do
            expect(form).to be_invalid
          end
        end
      end
    end
  end
end
