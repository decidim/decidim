# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Conference do
    subject { conference }

    let(:conference) { build(:conference, slug: "my-slug") }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    include_examples "publicable"
    include_examples "resourceable"

    context "when there is a conference with the same slug in the same organization" do
      let!(:external_conference) { create(:conference, organization: conference.organization, slug: "my-slug") }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:slug]).to eq ["has already been taken"]
      end
    end

    context "when there is a conference with the same slug in another organization" do
      let!(:external_conference) { create(:conference, slug: "my-slug") }

      it { is_expected.to be_valid }
    end

    describe "#has_published_registration_types?" do
      subject { conference.has_published_registration_types? }

      context "when conference has no registration type" do
        it { is_expected.to be_falsey }
      end

      context "when conference has registration types" do
        let!(:registration_types) do
          create_list(:registration_type, 5, conference:)
        end

        it { is_expected.to be_truthy }

        context "and the registration types are unpublished" do
          let!(:registration_types) do
            create_list(:registration_type, 5, :unpublished, conference:)
          end

          it { is_expected.to be_falsey }
        end
      end
    end
  end
end
