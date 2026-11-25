# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Like do
    subject { like }

    let!(:organization) { create(:organization) }
    let!(:component) { create(:component, organization:, manifest_name: "dummy") }
    let!(:participatory_process) { create(:participatory_process, organization:) }
    let!(:author) { create(:user, :confirmed, organization:) }
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
      let(:other_author) { create(:user, :confirmed) }
      let(:other_resource) { create(:dummy_resource) }

      it "is invalid" do
        like = build(:like, resource: other_resource, author: other_author)
        expect(like).to be_invalid
      end
    end

    context "when retrieving for_listing" do
      let!(:other_author) { create(:user, :confirmed, organization:) }
      let!(:last_like) { create(:like, resource:, author:, created_at: 1.day.ago) }
      let!(:first_like) { create(:like, resource:, author: other_author, created_at: 3.days.ago) }
      let!(:other_resource) { create(:dummy_resource, component:, users: [author]) }
      let!(:middle_like) { create(:like, resource: other_resource, author:, created_at: 2.days.ago) }

      it "sorts likes by created_at regardless of the author" do
        expect(Decidim::Like.for_listing.pluck(:id)).to eq([first_like.id, middle_like.id, last_like.id])
      end

      context "when likes have the same created_at" do
        let(:tied_at) { 4.days.ago }
        let(:tied_author) { create(:user, :confirmed, organization:) }
        # Inserted in reverse id order so the tiebreaker, not the insertion order, decides
        let!(:tied_like_with_higher_id) do
          create(:like, id: Decidim::Like.maximum(:id) + 2, resource: other_resource, author: other_author, created_at: tied_at)
        end
        let!(:tied_like_with_lower_id) do
          create(:like, id: tied_like_with_higher_id.id - 1, resource: other_resource, author: tied_author, created_at: tied_at)
        end

        it "sorts them by id" do
          expect(Decidim::Like.where(created_at: tied_at).for_listing.pluck(:id)).to eq([tied_like_with_lower_id.id, tied_like_with_higher_id.id])
        end
      end
    end
  end
end
