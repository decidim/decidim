# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::Commentable do
  subject { dummy_resource }

  let(:dummy_resource) { create :dummy_resource }

  describe "commentable" do
    let!(:top_level_comment) { create :comment, commentable: dummy_resource }
    let!(:second_level_comment) { create :comment, commentable: top_level_comment, root_commentable: dummy_resource }

    describe "comment_threads" do
      it "only returns top-level comments" do
        expect(subject.comment_threads).to eq [top_level_comment]
      end
    end

    describe "comments" do
      it "returns comments in all levels" do
        expect(subject.comments).to match_array [top_level_comment, second_level_comment]
      end
    end
  end

  describe "counter caches" do
    context "when a comment is created" do
      it "increments the counter" do
        expect(dummy_resource.reload.comments_count).to eq(0)

        expect do
          create(:comment, commentable: dummy_resource)
        end.to change { dummy_resource.reload.comments_count }.by(1)
      end
    end

    context "when a comment is destroyed" do
      let!(:comment) { create(:comment, commentable: dummy_resource) }

      it "decrements the counter" do
        expect(dummy_resource.reload.comments_count).to eq(1)

        expect do
          comment.destroy!
        end.to change { dummy_resource.reload.comments_count }.by(-1)
      end
    end

    context "when a comment is hidden" do
      let!(:comment) { create(:comment, commentable: dummy_resource) }

      it "decrements the counter" do
        expect(dummy_resource.reload.comments_count).to eq(1)

        expect do
          create(:moderation, :hidden, reportable: comment)
        end.to change { dummy_resource.reload.comments_count }.by(-1)
      end
    end

    context "when a comment is unhidden" do
      let!(:comment) { create(:comment, commentable: dummy_resource) }
      let!(:moderation) { create(:moderation, :hidden, reportable: comment) }

      it "increments the counter" do
        expect(dummy_resource.reload.comments_count).to eq(0)

        expect do
          moderation.hidden_at = nil
          moderation.save!
        end.to change { dummy_resource.reload.comments_count }.by(1)
      end
    end
  end
end
