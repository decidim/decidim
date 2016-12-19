# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Proposals
    describe ProposalForm do
      let(:feature) { create(:feature)}
      let(:title) { "Oriol for president!" }
      let(:body) { "Everything would be better" }
      let(:author) { create(:user, organization: feature.organization) }
      let(:category) { create(:category, participatory_process: feature.participatory_process) }
      let(:scope) { create(:scope, organization: feature.organization) }
      let(:category_id) { category.try(:id)}
      let(:scope_id) { scope.try(:id)}
      let(:params) do
        {
          title: title,
          body: body,
          author: author,
          category_id: category_id,
          scope_id: scope_id,
          feature: feature
        }
      end

      subject { described_class.from_params(params) }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when there's no title" do
        let(:title) { nil }
        it { is_expected.to be_invalid }
      end

      context "when there's no body" do
        let(:body) { nil }
        it { is_expected.to be_invalid }
      end

      context "when there's no author" do
        let(:author) { nil }
        it { is_expected.to be_invalid }
      end

      context "when no category_id" do
        let(:category_id) { nil }
        it { is_expected.to be_valid }
      end

      context "when no scope_id" do
        let(:scope_id) { nil }
        it { is_expected.to be_valid }
      end

      context "with invalid category_id" do
        let(:category_id) { 987 }
        it { is_expected.to be_invalid}
      end

      context "with invalid scope_id" do
        let(:scope_id) { 987 }
        it { is_expected.to be_invalid}
      end

      describe "category" do
        subject { described_class.from_params(params).category }

        context "when the category exists" do
          it { is_expected.to be_kind_of(Decidim::Category) }
        end

        context "when the category does not exist" do
          let(:category_id) { 7654 }
          it { is_expected.to eq(nil) }
        end

        context "when the category is from another process" do
          let(:category_id) { create(:category).id }
          it { is_expected.to eq(nil) }
        end
      end

      describe "scope" do
        subject { described_class.from_params(params).scope }

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
      end
    end
  end
end
