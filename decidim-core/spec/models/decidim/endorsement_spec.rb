# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Like do
    subject { like }

    let!(:organization) { create(:organization) }
    let!(:component) { create(:component, organization:, manifest_name: "dummy") }
    let!(:participatory_process) { create(:participatory_process, organization:) }
    let!(:author) { create(:user, organization:) }
    let!(:resource) { create(:dummy_resource, component:, users: [author]) }
    let!(:like) do
      build(:like, resource:, author:)
    end

    it "is valid" do
      expect(like).to be_valid
    end

    it "has an associated author" do
      expect(like.author).to be_a(Decidim::User)
    end

    it "has an associated resource" do
      expect(like.resource).to be_a(Decidim::Dev::DummyResource)
    end

    it "validates uniqueness for author and resource combination" do
      like.save!
      expect do
        create(:like, resource:, author:)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    context "when no author" do
      before do
        like.author = nil
      end

      it { is_expected.to be_invalid }
    end

    context "when no resource" do
      before do
        like.resource = nil
      end

      it { is_expected.to be_invalid }
    end

    context "when resource and author have different organization" do
      let(:other_author) { create(:user) }
      let(:other_resource) { create(:dummy_resource) }

      it "is invalid" do
        like = build(:like, resource: other_resource, author: other_author)
        expect(like).to be_invalid
      end
    end

    context "when retrieving for_listing" do
      before do
        like.save!
      end

      let!(:other_resource) { create(:dummy_resource, component:, users: [author]) }
      let!(:other_author) { create(:user, organization:) }
      let!(:other_endorsement1) do
        create(:like, resource:, author: other_author)
      end
      let!(:other_endorsement2) do
        create(:like, resource: other_resource, author:)
      end

      it "sorts user likes first and then by created_at" do
        expected_sorting = [
          like.id,
          other_endorsement2.id,
          other_endorsement1.id
        ]
        expect(Decidim::Like.for_listing.pluck(:id)).to eq(expected_sorting)
      end
    end
  end
end
