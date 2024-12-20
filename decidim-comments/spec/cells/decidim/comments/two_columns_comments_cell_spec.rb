# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe TwoColumnsCommentsCell, type: :cell do
      controller Decidim::Comments::CommentsController

      subject { my_cell.call }

      let(:my_cell) { cell("decidim/comments/two_columns_comments", commentable) }
      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:component) { create(:component, participatory_space: participatory_process) }
      let(:commentable) { create(:dummy_resource, component:) }

      before do
        allow(commentable).to receive(:closed?).and_return(false)
      end

      describe "#interleave_comments" do
        let!(:comments_in_favor) { create_list(:comment, 2, :in_favor, commentable:) }
        let!(:comments_against) { create_list(:comment, 3, :against, commentable:) }

        it "returns interleaved comments" do
          interleaved_comments = my_cell.send(:interleave_comments, comments_in_favor, comments_against)

          expected_result = [
            comments_in_favor[0], comments_against[0],
            comments_in_favor[1], comments_against[1],
            comments_against[2]
          ]

          expect(interleaved_comments).to eq(expected_result)
        end
      end

      describe "#interleave_top_comments" do
        let!(:top_comment_in_favor) { create(:comment, :in_favor, commentable:, up_votes_count: 10) }
        let!(:top_comment_against) { create(:comment, :against, commentable:, up_votes_count: 15) }

        before do
          allow(commentable).to receive(:closed?).and_return(true)
          my_cell.instance_variable_set(:@top_comment_in_favor, top_comment_in_favor)
          my_cell.instance_variable_set(:@top_comment_against, top_comment_against)
        end

        it "includes top comments in the beginning for closed models" do
          result = my_cell.send(:interleave_top_comments)

          expect(result).to eq([top_comment_in_favor, top_comment_against])
        end

        it "returns an empty array if the model is not closed" do
          allow(commentable).to receive(:closed?).and_return(false)

          result = my_cell.send(:interleave_top_comments)
          expect(result).to eq([])
        end
      end

      describe "#sorted_comments" do
        let!(:comments_in_favor) { create_list(:comment, 2, :in_favor, commentable:) }
        let!(:top_comment) { create(:comment, :in_favor, commentable:, up_votes_count: 20) }

        it "returns top comment and the rest sorted by creation date" do
          result = my_cell.send(:sorted_comments, commentable.comments.positive)

          expect(result.first).to eq(top_comment)
          expect(result.last).to match_array(comments_in_favor)
        end
      end

      context "when the model is closed" do
        let!(:comments_in_favor) { create_list(:comment, 2, :in_favor, commentable:) }
        let!(:comments_against) { create_list(:comment, 2, :against, commentable:) }
        let!(:top_comment_in_favor) { create(:comment, :in_favor, commentable:, up_votes_count: 10) }
        let!(:top_comment_against) { create(:comment, :against, commentable:, up_votes_count: 15) }

        before do
          allow(commentable).to receive(:closed?).and_return(true)
        end

        it "renders the top comments first" do
          within ".comments-two-columns" do
            expect(subject).to have_css(".most-upvoted-label", count: 2)
            expect(subject).to have_content(top_comment_in_favor.body.values.first)
            expect(subject).to have_content(top_comment_against.body.values.first)
          end
        end

        it "renders remaining comments interleaved" do
          interleaved_comments = [comments_in_favor[0], comments_against[0], comments_in_favor[1], comments_against[1]]

          interleaved_comments.each do |comment|
            expect(subject).to have_content(comment.body.values.first)
          end
        end
      end

      context "when the model is open" do
        let!(:comments_in_favor) { create_list(:comment, 2, :in_favor, commentable:) }
        let!(:comments_against) { create_list(:comment, 2, :against, commentable:) }

        before do
          allow(commentable).to receive(:closed?).and_return(false)
        end

        it "does not render top comments separately" do
          expect(subject).to have_no_css(".most-upvoted-label")
        end

        it "renders comments interleaved without prioritizing top comments" do
          interleaved_comments = [comments_in_favor[0], comments_against[0], comments_in_favor[1], comments_against[1]]

          interleaved_comments.each do |comment|
            expect(subject).to have_content(comment.body.values.first)
          end
        end
      end
    end
  end
end
