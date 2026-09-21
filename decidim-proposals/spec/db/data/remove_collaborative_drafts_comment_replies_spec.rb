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
    let!(:reply) do
      reply = create(:comment)
      reply.update_column(:decidim_root_commentable_type, collaborative_draft_type) # rubocop:disable Rails/SkipsModelValidations
      reply.update_column(:decidim_root_commentable_id, draft_id) # rubocop:disable Rails/SkipsModelValidations
      reply
    end

    let!(:other_comment) do
      create(:comment)
    end

    it "deletes replies whose root commentable is a collaborative draft" do
      expect(Decidim::Comments::Comment.where(decidim_root_commentable_type: collaborative_draft_type).count).to eq(1)
      migrator.migrate(:up)
      expect(Decidim::Comments::Comment.where(decidim_root_commentable_type: collaborative_draft_type).count).to eq(0)
    end

    it "keeps other comments" do
      migrator.migrate(:up)
      expect(Decidim::Comments::Comment.find_by(id: other_comment.id)).to be_present
    end
  end
end
