# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Assembly do
    subject { assembly }

    let(:assembly) { build(:assembly, slug: "my-slug") }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    include_examples "publicable"
    include_examples "resourceable"

    context "when there's an assembly with the same slug in the same organization" do
      let!(:external_assembly) { create :assembly, organization: assembly.organization, slug: "my-slug" }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:slug]).to eq ["has already been taken"]
      end
    end

    context "when there's an assembly with the same slug in another organization" do
      let!(:external_assembly) { create :assembly, slug: "my-slug" }

      it { is_expected.to be_valid }
    end

    describe "parents_path attribute" do
      subject { assembly.reload.parents_path }

      context "when the assembly is a root assembly" do
        let!(:assembly) { create(:assembly, slug: "my-slug") }

        it { is_expected.to eq(assembly.id.to_s) }
      end

      context "when the assembly has one ancestor" do
        let!(:assembly) { create :assembly, :with_parent }

        it { is_expected.to eq("#{assembly.parent.id}.#{assembly.id}") }
      end

      context "when the assembly has two or more ancestors" do
        let!(:assembly) { create :assembly, parent: create(:assembly, :with_parent) }

        it { is_expected.to eq("#{assembly.parent.parent.id}.#{assembly.parent.id}.#{assembly.id}") }
      end

      context "when changing the parent assembly" do
        let!(:assembly) { create :assembly, parent: create(:assembly, :with_parent) }
        let!(:new_parent_assembly) { create(:assembly) }

        it "updates the parents_path" do
          assembly.update!(parent: new_parent_assembly)
          expect(subject).to eq("#{new_parent_assembly.id}.#{assembly.id}")
        end

        it "updates parents_path on children assemblies" do
          assembly.parent.update!(parent: new_parent_assembly)
          expect(subject).to eq("#{new_parent_assembly.id}.#{assembly.parent.id}.#{assembly.id}")
        end
      end
    end

    describe "#self_and_ancestors" do
      subject { assembly.self_and_ancestors }

      context "when the assembly is a root assembly" do
        let!(:assembly) { create(:assembly, slug: "my-slug") }

        it { is_expected.to eq([assembly]) }
      end

      context "when the assembly has one ancestor" do
        let!(:assembly) { create :assembly, :with_parent }

        it { is_expected.to eq([assembly.parent, assembly]) }
      end

      context "when the assembly has two or more ancestors" do
        let!(:assembly) { create :assembly, parent: create(:assembly, :with_parent) }

        it { is_expected.to eq([assembly.parent.parent, assembly.parent, assembly]) }
      end
    end

    describe "#ancestors" do
      subject { assembly.ancestors }

      context "when the assembly is a root assembly" do
        let!(:assembly) { create(:assembly, slug: "my-slug") }

        it { is_expected.to eq([]) }
      end

      context "when the assembly has one ancestor" do
        let!(:assembly) { create :assembly, :with_parent }

        it { is_expected.to eq([assembly.parent]) }
      end

      context "when the assembly has two or more ancestors" do
        let!(:assembly) { create :assembly, parent: create(:assembly, :with_parent) }

        it { is_expected.to eq([assembly.parent.parent, assembly.parent]) }
      end
    end

    describe "scopes" do
      describe "public_spaces" do
        let!(:private_assembly) { create :assembly, :private, :opaque }
        let!(:private_transparent_assembly) { create :assembly, :private, :transparent }
        let!(:public_assembly) { create :assembly, :public }

        it "returns the public ones" do
          expect(described_class.public_spaces).to include private_transparent_assembly
          expect(described_class.public_spaces).to include public_assembly
          expect(described_class.public_spaces).not_to include private_assembly
        end
      end

      describe "active_spaces" do
        let!(:private_assembly) { create :assembly, :private, :opaque }
        let!(:private_transparent_assembly) { create :assembly, :private, :transparent }
        let!(:public_assembly) { create :assembly, :public }

        it "returns the public ones" do
          expect(described_class.active_spaces).to include private_transparent_assembly
          expect(described_class.active_spaces).to include public_assembly
          expect(described_class.active_spaces).not_to include private_assembly
        end
      end

      describe "future_spaces" do
        it "returns none" do
          expect(described_class.future_spaces).to eq ApplicationRecord.none
        end
      end

      describe "past_spaces" do
        it "returns none" do
          expect(described_class.past_spaces).to eq ApplicationRecord.none
        end
      end
    end

    describe "types" do
      let!(:assembly) { create :assembly, :with_type }

      it { is_expected.to be_valid }
    end
  end
end
