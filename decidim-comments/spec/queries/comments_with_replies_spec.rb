# frozen_string_literal: true
require "spec_helper"

describe Decidim::Comments::CommentsWithReplies do
  let!(:organization) { create(:organization) }
  let!(:author) { create(:user, organization: organization) }
  let!(:commentable) { create(:participatory_process, organization: organization) }
  let!(:comment) { create(:comment, commentable: commentable, author: author) }
  let!(:order_by) {}

  subject { described_class.new(commentable, order_by: order_by) }
  
  it "returns the commentable's comments" do
    expect(subject.query).to eq [comment]
  end

  it "eager loads comment's author, up_votes and down_votes" do
    comment = subject.query[0]
    expect {
      expect(comment.author.name).to be_present
      expect(comment.up_votes.size).to eq(0)
      expect(comment.down_votes.size).to eq(0)        
    }.to_not make_database_queries
  end

  it "eager loads a comment tree based on the MAX_DEPTH" do
    reply = comment
    
    Decidim::Comments::Comment::MAX_DEPTH.times do
      reply = create(:comment, commentable: reply)
    end

    comment = subject.query[0]

    expect {
      Decidim::Comments::Comment::MAX_DEPTH.times do
        comment = comment.replies[0]
      end
      expect(comment.author.name).to be_present
      expect(comment.up_votes.size).to eq(0)
      expect(comment.down_votes.size).to eq(0)
    }.to_not make_database_queries
  end

  it "return the comments ordered by created_at asc by default" do
    previous_comment = create(:comment, commentable: commentable, author: author, created_at: 1.week.ago, updated_at: 1.week.ago)
    future_comment = create(:comment, commentable: commentable, author: author, created_at: 1.week.from_now, updated_at: 1.week.from_now)    
    expect(subject.query).to eq [previous_comment, comment, future_comment]    
  end
    
  context "When order_by is not default" do
    context "When order by recent" do
      let!(:order_by) {"recent"}
      it "return the comments ordered by recent" do
        previous_comment = create(:comment, commentable: commentable, author: author, created_at: 1.week.ago, updated_at: 1.week.ago)
        future_comment = create(:comment, commentable: commentable, author: author, created_at: 1.week.from_now, updated_at: 1.week.from_now)    
        expect(subject.query).to eq [previous_comment, comment, future_comment].reverse 
      end
    end
    
    context "When order by best_rated" do
      let!(:order_by) {"best_rated"}
      it "return the comments ordered by best_rated" do
        most_voted_comment = create(:comment, commentable: commentable, author: author, created_at: 1.week.ago, updated_at: 1.week.ago)
        create(:comment_vote, comment: most_voted_comment, author: author, weight: 1)
        less_voted_comment = create(:comment, commentable: commentable, author: author, created_at: 1.week.from_now, updated_at: 1.week.from_now)  
        create(:comment_vote, comment: less_voted_comment, author: author, weight: -1)
 
        expect(subject.query).to eq [most_voted_comment, comment, less_voted_comment] 
      end
    end

    context "When order by most_discussed" do
      let!(:order_by) {"most_discussed"}
      it "return the comments ordered by most_discussed" do
        most_commented = create(:comment, commentable: commentable, author: author, created_at: 1.week.ago, updated_at: 1.week.ago)
        3.times.map do
          create(:comment, commentable:  most_commented)
        end
        create(:comment, commentable: comment)
        less_commented = create(:comment, commentable: commentable, author: author, created_at: 1.week.from_now, updated_at: 1.week.from_now)    
        expect(subject.query).to eq [most_commented, comment, less_commented]
      end
    end
  end
end