# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Assembly do
    let(:assembly) { build(:assembly, slug: "my-slug") }
    subject { assembly }

    it { is_expected.to be_valid }

    include_examples "publicable"

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
  end
end
