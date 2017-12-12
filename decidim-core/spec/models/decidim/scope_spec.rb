# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Scope do
    subject(:scope) { build(:scope, parent: parent) }

    let(:parent) { nil }

    describe "has an association for children scopes" do
      subject(:scope_children) { scope.children }

      let(:scopes) { create_list(:scope, 2, parent: scope) }

      it { is_expected.to contain_exactly(*scopes) }
    end

    context "when it is valid" do
      it { is_expected.to be_valid }
    end

    context "with two scopes with the same code and organization" do
      let!(:existing_scope) { create(:scope, code: scope.code, organization: scope.organization) }

      it { is_expected.to be_invalid }
    end

    context "with two scopes with the same code in different organizations" do
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

    describe "cycles validation" do
      subject(:scope) { create(:scope) }

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

    describe "part_of for top level scopes" do
      it "is empty before save" do
        expect(subject.part_of).to be_empty
      end

      it "is updated after save" do
        subject.save
        expect(subject.part_of).to eq([subject.id])
      end

      context "with parent scope" do
        let(:parent) { create(:scope) }

        it "is updated after save" do
          subject.save
          expect(subject.part_of).to eq([subject.id, parent.id])
        end
      end
    end

    describe "#part_of_scopes" do
      let(:grandparent) { create(:scope) }
      let(:parent) { create(:scope, parent: grandparent) }

      it "returns correct path" do
        subject.save
        expect(subject.part_of_scopes).to eq([grandparent, parent, scope])
      end
    end

    describe "creating several scopes on a transaction" do
      let(:scopes) { build_list(:scope, 9) }

      before do
        Scope.transaction do
          scopes.each_with_index do |scope, i|
            scope.parent_id = scopes[i / 2].id if i.positive?
            scope.save!
          end
        end
      end

      it "updates part_of lists" do
        {
          0 => [0],
          1 => [1, 0],
          2 => [2, 1, 0],
          3 => [3, 1, 0],
          4 => [4, 2, 1, 0]
        }.each do |s1, list|
          expect(scopes[s1].part_of).to eq(list.map { |i| scopes[i].id })
        end
      end
    end
  end
end
