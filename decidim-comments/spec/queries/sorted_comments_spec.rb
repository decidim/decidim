# frozen_string_literal: true

require "spec_helper"

module Decidim::Comments
  describe SortedComments do
    subject { described_class.new(commentable, options) }

    let(:options) do
      {
        order_by:,
        id:,
        after:
      }
    end
    let(:id) { nil }
    let(:after) { nil }
    let!(:organization) { create(:organization) }
    let!(:participatory_process) { create(:participatory_process, organization:) }
    let!(:component) { create(:component, participatory_space: participatory_process) }
    let!(:author) { create(:user, organization:) }
    let!(:commentable) { create(:dummy_resource, component:) }
    let!(:comment) { create(:comment, commentable:, author:) }
    let!(:order_by) { nil }

    it "returns the commentable's comments" do
      expect(subject.query).to eq [comment]
    end

    it "eager loads comment's author, up_votes and down_votes" do
      comment = subject.query[0]
      expect do
        expect(comment.author.name).to be_present
        expect(comment.up_votes.size).to eq(0)
        expect(comment.down_votes.size).to eq(0)
      end.not_to make_database_queries
    end

    it "return the comments ordered by created_at asc by default" do
      previous_comment = create(:comment, commentable:, author:, created_at: 1.week.ago, updated_at: 1.week.ago)
      future_comment = create(:comment, commentable:, author:, created_at: 1.week.from_now, updated_at: 1.week.from_now)
      expect(subject.query).to eq [previous_comment, comment, future_comment]
    end

    context "when filtering by id" do
      let!(:another_comment) { create(:comment, commentable:, author:) }
      let(:id) { comment.id }

      it "only returns the requested comment" do
        expect(subject.query).to eq [comment]
      end
    end

    context "when filtering comments after id" do
      let!(:comments) { create_list(:comment, 10, commentable:, author:) }
      let(:after) { comments.first.id }

      it "only returns the comments after the specified id" do
        expect(subject.query).to eq(comments[1..-1])
      end

      context "when the after comments contain replies" do
        let(:replies) { create_list(:comment, 5, commentable: comment, root_commentable: commentable, author:) }
        let(:after) { comments.last.id }

        it "returns the replies" do
          expect(subject.query).to eq(replies)
        end
      end
    end

    context "when the comment is hidden" do
      before do
        moderation = create(:moderation, reportable: comment, participatory_space: comment.component.participatory_space, report_count: 1, hidden_at: Time.current)
        create(:report, moderation:)
      end

      it "is included in the query" do
        expect(subject.query).not_to be_empty
      end
    end

    context "when order_by is not default" do
      context "when order by recent" do
        let!(:order_by) { "recent" }

        it "return the comments ordered by recent" do
          previous_comment = create(:comment, commentable:, author:, created_at: 1.week.ago, updated_at: 1.week.ago)
          future_comment = create(:comment, commentable:, author:, created_at: 1.week.from_now, updated_at: 1.week.from_now)
          expect(subject.query).to eq [previous_comment, comment, future_comment].reverse
        end
      end

      context "when order by best_rated" do
        let!(:order_by) { "best_rated" }

        it "return the comments ordered by best_rated" do
          most_voted_comment = create(:comment, commentable:, author:, created_at: 1.week.ago, updated_at: 1.week.ago)
          less_voted_comment = create(:comment, commentable:, author:, created_at: 1.week.from_now, updated_at: 1.week.from_now)
          create(:comment_vote, comment: most_voted_comment, author:, weight: 1)
          create(:comment_vote, comment: less_voted_comment, author:, weight: -1)
          expect(subject.query).to eq [most_voted_comment, comment, less_voted_comment]
        end
      end

      context "when order by most_discussed" do
        let!(:order_by) { "most_discussed" }

        it "return the comments ordered by most_discussed" do
          most_commented = create(:comment, commentable:, author:, created_at: 1.week.ago, updated_at: 1.week.ago)
          less_commented = create(:comment, commentable:, author:, created_at: 1.week.from_now, updated_at: 1.week.from_now)
          create(:comment, commentable: comment)
          create_list(:comment, 3, commentable: most_commented)
          expect(subject.query).to eq [most_commented, comment, less_commented]
        end
      end
    end
  end
end
