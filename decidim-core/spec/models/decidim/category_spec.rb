# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Category do
    subject { category }

    let(:category) { build(:category) }

    it { is_expected.to be_valid }

    context "when it has a parent" do
      let(:category) { create(:subcategory) }

      it { is_expected.to be_valid }
    end

    context "when its parent has a parent" do
      let(:subcategory) { create(:subcategory) }
      let(:category) { build(:category, parent: subcategory) }

      it { is_expected.not_to be_valid }

      it "adds an error" do
        subject.valid?
        expect(subject.errors[:parent_id]).to eq ["can't be inside of a subcategory"]
      end
    end

    context "without a participatory space" do
      let(:parent) { create(:category) }
      let(:category) { create(:subcategory, parent: parent, participatory_space: nil) }

      it "is saved to parent before save" do
        subject.save
        expect(subject.participatory_space).to eq parent.participatory_space
      end
    end
  end
end
