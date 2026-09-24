# frozen_string_literal: true

require "spec_helper"

require "./db/data/20260921122323_remove_collaborative_drafts_comment_replies"

describe RemoveCollaborativeDraftsCommentReplies do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  let(:collaborative_draft_type) { "Decidim::Proposals::CollaborativeDraft" }
  let(:draft_id) { 999_999 }

  describe "#up" do
    let(:reply) { create(:comment) }
    let!(:vote) { create(:comment_vote, comment: reply) }
    let!(:moderation) { create(:moderation, reportable: reply) }
    let!(:report) { create(:report, moderation:) }
    let!(:other_comment) { create(:comment) }

    before do
      reply.update_column(:decidim_root_commentable_type, collaborative_draft_type) # rubocop:disable Rails/SkipsModelValidations
      reply.update_column(:decidim_root_commentable_id, draft_id) # rubocop:disable Rails/SkipsModelValidations
    end

    it "deletes replies whose root commentable is a collaborative draft" do
      expect(Decidim::Comments::Comment.where(decidim_root_commentable_type: collaborative_draft_type).count).to eq(1)
      migrator.migrate(:up)
      expect(Decidim::Comments::Comment.where(decidim_root_commentable_type: collaborative_draft_type).count).to eq(0)
    end

    it "deletes the votes, search index entries and reports of those replies" do
      migrator.migrate(:up)
      expect(Decidim::Comments::CommentVote.find_by(id: vote.id)).to be_nil
      expect(Decidim::SearchableResource.where(resource_type: "Decidim::Comments::Comment", resource_id: reply.id)).to be_empty
      expect(Decidim::Moderation.find_by(id: moderation.id)).to be_nil
      expect(Decidim::Report.find_by(id: report.id)).to be_nil
    end

    it "keeps other comments" do
      migrator.migrate(:up)
      expect(Decidim::Comments::Comment.find_by(id: other_comment.id)).to be_present
    end
  end
end
