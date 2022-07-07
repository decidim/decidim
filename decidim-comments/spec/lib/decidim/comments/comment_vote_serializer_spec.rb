# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentVoteSerializer do
      let(:comment) { create(:comment) }
      let(:serialized) { subject.serialize }
      let(:resource) { create(:comment_vote, comment: comment) }

      subject { described_class.new(resource) }

      describe "#serialize" do
        it "includes the id" do
          expect(serialized).to include(id: resource.id)
        end

        it "includes the weight" do
          expect(serialized).to include(weight: resource.weight)
        end

        it "includes the comment" do
          expect(serialized[:comment]).to include(id: resource.comment.id)
          expect(serialized[:comment]).to include(created_at: resource.comment.created_at)
          expect(serialized[:comment]).to include(body: resource.comment.body)
          expect(serialized[:comment][:author]).to(
            include(id: comment.author.id, name: resource.comment.author.name)
          )
          expect(serialized[:comment]).to include(alignment: resource.comment.alignment)
          expect(serialized[:comment]).to include(alignment: resource.comment.depth)
          expect(serialized[:comment][:root_commentable_url]).to match(/http/)
        end

        it "includes the creation date" do
          expect(serialized).to include(created_at: resource.created_at)
        end

        it "includes the updated date" do
          expect(serialized).to include(updated_at: resource.updated_at)
        end
      end
    end
  end
end
