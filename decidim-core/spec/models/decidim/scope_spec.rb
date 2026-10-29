# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Scope do
    subject(:scope) { build(:scope, parent:) }

    let(:parent) { nil }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    describe "has an association for children scopes" do
      subject(:scope_children) { scope.children }

      let(:scopes) { create_list(:scope, 2, parent: scope) }

      it { is_expected.to match_array(scopes) }
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

    describe "reciprocal associations" do
      subject(:scope) { create(:scope, organization:) }

      let(:organization) { create(:organization) }
      let(:other_organization) { create(:organization) }
      let(:other_scope) { create(:scope, organization: other_organization) }

      shared_examples "scope reciprocal association" do |association, owner, cascaded: true|
        before do
          record
          other_record
        end

        it "only includes the records of its own scope" do
          expect(scope.public_send(association)).to contain_exactly(record)
        end

        it "does not include the records of another scope, even when it is in another organization" do
          expect(scope.public_send(association)).not_to include(other_record)
        end

        it "points back to the scope from the records loaded through the association" do
          expect(scope.public_send(association).first.public_send(owner)).to eq(scope)
        end

        if cascaded == :nullify
          it "keeps the records when the scope is destroyed, only clearing their scope" do
            scope.destroy

            expect(record.class.where(id: record.id)).to exist
            expect(record.reload.public_send(owner)).to be_nil
            expect(other_record.reload.public_send(owner)).to eq(other_scope)
          end
        elsif cascaded
          it "deletes the records when the scope is destroyed" do
            scope.destroy

            expect(record.class.where(id: record.id)).to be_empty
            expect(other_record.class.where(id: other_record.id)).to exist
          end
        else
          it "keeps the records when the scope is destroyed, as they are not cascaded" do
            scope.destroy

            expect(record.class.where(id: record.id)).to exist
            expect(other_record.class.where(id: other_record.id)).to exist
          end
        end
      end

      context "with action logs" do
        let(:record) { create(:action_log, organization:, scope:, user: create(:user, organization:)) }
        let(:other_record) { create(:action_log, organization: other_organization, scope: other_scope, user: create(:user, organization: other_organization)) }

        it_behaves_like "scope reciprocal association", :action_logs, :scope, cascaded: false
      end

      context "with searchable resources" do
        let(:record) { create(:searchable_resource, organization:, scope:) }
        let(:other_record) { create(:searchable_resource, organization: other_organization, scope: other_scope) }

        it_behaves_like "scope reciprocal association", :searchable_resources, :scope, cascaded: :nullify

        it "keeps the indexed resource searchable, as the resource is not destroyed with the scope" do
          record

          scope.destroy

          expect(record.class.where(id: record.id)).to exist
          expect(record.reload.resource).to be_persisted
        end
      end
    end

    describe "cycles validation" do
      subject(:scope) { create(:scope) }

      let(:subscope) { create(:subscope, parent: scope) }
      let(:subsubscope) { create(:subscope, parent: subscope) }

      it "do not allows two scopes cycles" do
        scope.parent = subscope
        expect(subject).to be_invalid
      end

      it "do not allows three scopes cycles" do
        scope.parent = subsubscope
        expect(subject).to be_invalid
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
