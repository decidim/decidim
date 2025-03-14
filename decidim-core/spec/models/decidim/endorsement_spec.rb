# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Endorsement do
    subject { endorsement }

    let!(:organization) { create(:organization) }
    let!(:component) { create(:component, organization:, manifest_name: "dummy") }
    let!(:participatory_process) { create(:participatory_process, organization:) }
    let!(:author) { create(:user, organization:) }
    let!(:resource) { create(:dummy_resource, component:, users: [author]) }
    let!(:endorsement) do
      build(:endorsement, resource:, author:)
    end

    it "is valid" do
      expect(endorsement).to be_valid
    end

    it "has an associated author" do
      expect(endorsement.author).to be_a(Decidim::User)
    end

    it "has an associated resource" do
      expect(endorsement.resource).to be_a(Decidim::Dev::DummyResource)
    end

    it "validates uniqueness for author and resource combination" do
      endorsement.save!
      expect do
        create(:endorsement, resource:, author:)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    context "when no author" do
      before do
        endorsement.author = nil
      end

      it { is_expected.to be_invalid }
    end

    context "when no resource" do
      before do
        endorsement.resource = nil
      end

      it { is_expected.to be_invalid }
    end

    context "when resource and author have different organization" do
      let(:other_author) { create(:user) }
      let(:other_resource) { create(:dummy_resource) }

      it "is invalid" do
        endorsement = build(:endorsement, resource: other_resource, author: other_author)
        expect(endorsement).to be_invalid
      end
    end

    context "when retrieving for_listing" do
      before do
        endorsement.save!
      end

      let!(:other_resource) { create(:dummy_resource, component:, users: [author]) }
      let!(:other_author) { create(:user, organization:) }
      let!(:other_endorsement1) do
        create(:endorsement, resource:, author: other_author)
      end
      let!(:other_endorsement2) do
        create(:endorsement, resource: other_resource, author:)
      end

      it "sorts user endorsements first and then by created_at" do
        expected_sorting = [
          endorsement.id,
          other_endorsement2.id,
          other_endorsement1.id
        ]
        expect(Decidim::Endorsement.for_listing.pluck(:id)).to eq(expected_sorting)
      end
    end
  end
end
