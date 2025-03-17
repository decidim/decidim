# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Comments
    describe CommentType do
      include_context "with a graphql class type"

      let(:model) { create(:comment) }
      let(:sgid) { double("sgid", to_s: "1234") }

      context "when participatory space is unpublished" do
        let(:participatory_space) { create(:assembly, :unpublished) }
        let(:component) { create(:dummy_component, :published, participatory_space:) }
        let(:commentable) { create(:dummy_resource, :published, component:) }
        let!(:moderation) { create(:moderation, reportable: commentable, hidden_at: 2.days.ago) }

        let(:model) { create(:comment, commentable:) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when participatory space is private and transparent" do
        let(:participatory_space) { create(:assembly, :published, :transparent, :private) }
        let(:component) { create(:dummy_component, :published, participatory_space:) }
        let(:commentable) { create(:dummy_resource, :published, component:) }
        let(:model) { create(:comment, commentable:) }
        let(:query) { "{ id }" }

        it "returns the model" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      context "when participatory space is private" do
        let(:participatory_space) { create(:assembly, :published, :private, :opaque) }
        let(:component) { create(:dummy_component, :published, participatory_space:) }
        let(:commentable) { create(:dummy_resource, :published, component:) }

        let(:model) { create(:comment, commentable:) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when component is unpublished" do
        let(:component) { create(:dummy_component, :unpublished) }
        let(:commentable) { create(:dummy_resource, :published, component:) }

        let(:model) { create(:comment, commentable:) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when resource is unpublished" do
        let(:commentable) { create(:dummy_resource) }

        let(:model) { create(:comment, commentable:) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      context "when resource is moderated" do
        let(:commentable) { create(:dummy_resource, :published) }
        let!(:moderation) { create(:moderation, reportable: commentable, hidden_at: 2.days.ago) }

        let(:model) { create(:comment, commentable:) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      describe "deleted comment" do
        let(:model) { create(:comment, :deleted) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      describe "moderated comment" do
        let(:model) { create(:comment, :moderated) }
        let(:query) { "{ id }" }

        it "returns nothing" do
          expect(response).to be_nil
        end
      end

      describe "author" do
        let(:query) { "{ author { name } }" }
        let(:commentable) { build(:dummy_resource, :published) }
        let(:model) do
          create(:comment, author:, commentable:)
        end

        context "when the author is a user" do
          let(:author) { create(:user, :confirmed, organization: commentable.organization) }

          it "returns the user" do
            expect(response).to include("author" => { "name" => author.name })
          end
        end
      end

      describe "sgid" do
        let(:query) { "{ sgid }" }

        it "returns its signed global id" do
          expect(model).to receive(:to_sgid).at_least(:once).and_return(sgid)
          expect(response).to include("sgid" => model.to_sgid.to_s)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns its created_at field to iso format" do
          expect(response).to include("createdAt" => model.created_at.to_time.iso8601)
        end
      end

      describe "hasComments" do
        let(:query) { "{ hasComments }" }

        it "returns false if the comment has not comments" do
          expect(response).to include("hasComments" => false)
        end

        it "returns true if the comment has comments" do
          FactoryBot.create(:comment, commentable: model)
          expect(response).to include("hasComments" => true)
        end

        context "when comment child has been moderated" do
          let(:comment) { create(:comment, commentable: model) }

          it "return false" do
            Decidim::Moderation.create!(reportable: comment, participatory_space: comment.participatory_space, hidden_at: 1.day.ago)

            expect(response).to include("hasComments" => false)
          end
        end
      end

      describe "acceptsNewComments" do
        let(:query) { "{ acceptsNewComments }" }

        it "returns the return value of accepts_new_comments? method" do
          expect(response).to include("acceptsNewComments" => model.accepts_new_comments?)
        end
      end

      describe "comments" do
        let!(:random_comment) { FactoryBot.create(:comment) }
        let!(:replies) { Array.new(3) { |n| FactoryBot.create(:comment, commentable: model, created_at: Time.current - n.days) } }

        let(:query) { "{ comments { id } }" }

        it "return comment's comments data" do
          replies.each do |reply|
            expect(response["comments"]).to include("id" => reply.id.to_s)
          end
          expect(response["comments"]).not_to include("id" => random_comment.id.to_s)
        end

        it "return comment's comments ordered by date" do
          response_ids = response["comments"].map { |reply| reply["id"].to_i }
          replies_ids = replies.sort_by(&:created_at).map(&:id)
          expect(response_ids).to eq(replies_ids)
        end
      end

      describe "alignment" do
        let(:query) { "{ alignment }" }

        it "returns the alignment field" do
          expect(response).to include("alignment" => model.alignment)
        end
      end

      describe "upVotes" do
        let(:query) { "{ upVotes }" }

        it "returns the up_votes count" do
          expect(response).to include("upVotes" => model.up_votes.count)
        end
      end

      describe "downVotes" do
        let(:query) { "{ downVotes }" }

        it "returns the down_votes count" do
          expect(response).to include("downVotes" => model.down_votes.count)
        end
      end

      describe "upVoted" do
        let(:query) { "{ upVoted }" }

        it "returns the up_voted_by? method evaluation with the current user" do
          allow(model).to receive(:up_voted_by?).with(current_user).and_return(true)
          expect(response).to include("upVoted" => true)
        end
      end

      describe "downVoted" do
        let(:query) { "{ downVoted }" }

        it "returns the down_voted_by? method evaluation with the current user" do
          allow(model).to receive(:down_voted_by?).with(current_user).and_return(true)
          expect(response).to include("downVoted" => true)
        end
      end

      describe "alreadyReported" do
        let(:query) { "{ alreadyReported }" }

        it "returns the reported_by? method evaluation with the current user" do
          allow(model).to receive(:reported_by?).with(current_user).and_return(true)
          expect(response).to include("alreadyReported" => true)
        end
      end
    end
  end
end
