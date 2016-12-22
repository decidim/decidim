# frozen_string_literal: true
require "spec_helper"

describe Decidim::Comments::CommentsWithReplies do
  let!(:organization) { create(:organization) }
  let!(:author) { create(:user, organization: organization) }
  let!(:commentable) { create(:participatory_process, organization: organization) }
  let!(:comment) { create(:comment, commentable: commentable, author: author) }

  subject { described_class.new(commentable) }
  
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

  it "return the comments ordered by created_at asc" do
    previous_comment = create(:comment, commentable: commentable, author: author, created_at: 1.week.ago, updated_at: 1.week.ago)
    future_comment = create(:comment, commentable: commentable, author: author, created_at: 1.week.from_now, updated_at: 1.week.from_now)    
    expect(subject.query).to eq [previous_comment, comment, future_comment]    
  end
end