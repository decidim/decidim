# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Scope do
    let(:parent) { nil }
    let(:scope) { build(:scope, parent: parent) }
    subject { scope }

    context "it is valid" do
      it { is_expected.to be_valid }
    end

    context "two scopes with the same code and organization" do
      let!(:existing_scope) { create(:scope, code: scope.code, organization: scope.organization) }

      it { is_expected.to be_invalid }
    end

    context "two scopes with the same code in different organizations" do
      let!(:existing_scope) { create(:scope, code: scope.code) }

      it { is_expected.to be_valid }
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

    context "cycles validation" do
      let(:scope) { create(:scope) }
      let(:subscope) { create(:subscope, parent: scope) }
      let(:subsubscope) { create(:subscope, parent: subscope) }

      it "don't allows two scopes cycles" do
        scope.parent = subscope
        is_expected.to be_invalid
      end

      it "don't allows three scopes cycles" do
        scope.parent = subsubscope
        is_expected.to be_invalid
      end
    end

    context "part_of for top level scopes" do
      it "is empty before save" do
        expect(subject.part_of).to be_empty
      end

      it "is updated after save" do
        subject.save
        expect(subject.part_of).to eq([subject.id])
      end
    end

    context "part_of for top level scopes" do
      let(:parent) { create(:scope) }

      it "is updated after save" do
        subject.save
        expect(subject.part_of).to eq([subject.id, parent.id])
      end
    end
  end
end
