# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Scope do
    let(:scope) { create(:scope) }
    subject { scope }

    it { is_expected.to be_valid }

    context "two scopes with the same code and organization" do
      let(:invalid_scope) { build(:scope, code: scope.code, organization: scope.organization) }

      it { expect(invalid_scope).to be_invalid }
    end

    context "two scopes with the same code in different organizations" do
      let(:other_scope) { build(:scope, code: scope.code) }

      it { expect(other_scope).to be_valid }
    end

    context "without name" do
      before do
        scope.name = {}
      end

      it { is_expected.to be_invalid }
    end

    context "without code" do
      before do
        scope.code = ""
      end

      it { is_expected.to be_invalid }
    end

    context "without organization" do
      before do
        scope.organization = nil
      end

      it { is_expected.to be_invalid }
    end

    let(:subscope) { create(:subscope, parent: scope) }
    let(:subsubscope) { create(:subscope, parent: subscope) }
    context "a simple cycle of two scopes" do
      before do
        scope.parent = subscope
      end

      it { is_expected.to be_invalid }
    end

    context "a cycle of three scopes" do
      before do
        scope.parent = subsubscope
      end

      it { is_expected.to be_invalid }
    end
  end
end
