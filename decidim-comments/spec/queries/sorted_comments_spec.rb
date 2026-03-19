# frozen_string_literal: true

require "spec_helper"

module Decidim::Comments
  describe SortedComments do
    subject { described_class.new(commentable, options) }

    let(:options) do
      {
        order_by:,
        id:
      }
    end
    let(:id) { nil }
    let!(:organization) { create(:organization) }
    let!(:participatory_process) { create(:participatory_process, organization:) }
    let!(:component) { create(:component, participatory_space: participatory_process) }
    let!(:author) { create(:user, organization:) }
    let!(:commentable) { create(:dummy_resource, component:) }
    let!(:comment) { create(:comment, commentable:, author:) }
    let!(:order_by) { nil }

    it "returns the commentable's comments" do
      expect(subject.query.to_a).to eq [comment]
    end

    it "eager loads comment's author" do
      comment = subject.query[0]
      begin
        subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |_, _, _, _, data|
          raise RSpec::Expectations::ExpectationNotMetError, "N+1 detected - #{data[:sql]}" if data[:sql] =~ /SELECT\s+.*\s+FROM\s/
        end

        expect(comment.author.name).to be_present
      rescue RSpec::Expectations::ExpectationNotMetError => e
        ActiveSupport::Notifications.unsubscribe(subscriber)
        raise e
      ensure
        ActiveSupport::Notifications.unsubscribe(subscriber)
      end
    end

    it "return the comments ordered by created_at asc by default" do
      previous_comment = create(:comment, commentable:, author:, created_at: 1.week.ago, updated_at: 1.week.ago)
      future_comment = create(:comment, commentable:, author:, created_at: 1.week.from_now, updated_at: 1.week.from_now)
      expect(subject.query.to_a).to eq [previous_comment, comment, future_comment]
    end

    context "when filtering by id" do
      let!(:another_comment) { create(:comment, commentable:, author:) }
      let(:id) { comment.id }

      it "only returns the requested comment" do
        expect(subject.query.to_a).to eq [comment]
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

    context "when using pagination with limit" do
      let!(:extra_comments) { create_list(:comment, 15, commentable:, author:) }
      let(:options) { { order_by:, id:, limit: 5 } }

      it "returns only the limited number of comments" do
        expect(subject.query.size).to eq(5)
      end

      it "returns total_count with all comments" do
        expect(subject.total_count).to eq(16)
      end
    end

    context "when using pagination with offset and limit" do
      let!(:extra_comments) { create_list(:comment, 15, commentable:, author:) }
      let(:options) { { order_by:, id:, offset: 5, limit: 5 } }

      it "skips the first comments and returns the next batch" do
        expect(subject.query.size).to eq(5)
        expect(subject.query.to_a.first).to eq(extra_comments[4])
      end
    end

    context "when filtering by alignment" do
      let!(:comments_in_favor) { create_list(:comment, 3, :in_favor, commentable:, author:) }
      let!(:comments_against) { create_list(:comment, 2, :against, commentable:, author:) }
      let(:options) { { order_by:, id:, alignment: 1 } }

      it "returns only in_favor comments" do
        expect(subject.query.to_a).to match_array(comments_in_favor)
        expect(subject.total_count).to eq(3)
      end

      context "when filtering against comments" do
        let(:options) { { order_by:, id:, alignment: -1 } }

        it "returns only against comments" do
          expect(subject.query.to_a).to match_array(comments_against)
          expect(subject.total_count).to eq(2)
        end
      end

      context "when combining alignment with pagination" do
        let(:options) { { order_by:, id:, alignment: 1, limit: 2 } }

        it "applies both filters correctly" do
          expect(subject.query.size).to eq(2)
          expect(subject.query.to_a).to all(satisfy { |c| c.alignment == 1 })
        end
      end
    end

    context "when order_by is not default" do
      context "when order by recent" do
        let!(:order_by) { "recent" }

        it "return the comments ordered by recent" do
          previous_comment = create(:comment, commentable:, author:, created_at: 1.week.ago, updated_at: 1.week.ago)
          future_comment = create(:comment, commentable:, author:, created_at: 1.week.from_now, updated_at: 1.week.from_now)
          expect(subject.query.to_a).to eq [previous_comment, comment, future_comment].reverse
        end
      end

      context "when order by best_rated" do
        let!(:order_by) { "best_rated" }

        it "return the comments ordered by best_rated" do
          most_voted_comment = create(:comment, commentable:, author:, created_at: 1.week.ago, updated_at: 1.week.ago)
          less_voted_comment = create(:comment, commentable:, author:, created_at: 1.week.from_now, updated_at: 1.week.from_now)
          create(:comment_vote, comment: most_voted_comment, author:, weight: 1)
          create(:comment_vote, comment: less_voted_comment, author:, weight: -1)
          expect(subject.query.to_a).to eq [most_voted_comment, comment, less_voted_comment]
        end
      end

      context "when order by most_discussed" do
        let!(:order_by) { "most_discussed" }

        it "return the comments ordered by most_discussed" do
          most_commented = create(:comment, commentable:, author:, created_at: 1.week.ago, updated_at: 1.week.ago)
          less_commented = create(:comment, commentable:, author:, created_at: 1.week.from_now, updated_at: 1.week.from_now)
          create(:comment, commentable: comment)
          create_list(:comment, 3, commentable: most_commented)
          expect(subject.query.to_a).to eq [most_commented, comment, less_commented]
        end
      end
    end
  end
end
