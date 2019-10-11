# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Conference do
    subject { conference }

    let(:conference) { build(:conference, :with_custom_link, slug: "my-slug") }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    include_examples "publicable"
    include_examples "resourceable"

    context "when there's an conference with the same slug in the same organization" do
      let!(:external_conference) { create :conference, organization: conference.organization, slug: "my-slug" }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:slug]).to eq ["has already been taken"]
      end
    end

    context "when there's an conference with the same slug in another organization" do
      let!(:external_conference) { create :conference, slug: "my-slug" }

      it { is_expected.to be_valid }
    end
  end
end
