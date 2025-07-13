# frozen_string_literal: true

require "spec_helper"

module Decidim::Comments
  describe CommentThreadCell, type: :cell do
    controller Decidim::Comments::CommentsController

    subject { my_cell.call }

    let(:my_cell) { cell("decidim/comments/comment_thread", comment) }
    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:component) { create(:component, participatory_space: participatory_process) }
    let(:commentable) { create(:dummy_resource, component:) }
    let(:comment) { create(:comment, commentable:) }

    context "when rendering" do
      before do
        allow(comment).to receive(:created_at).and_return(Time.zone.parse("2018-02-01 12:30:15"))
      end

      it "renders the thread" do
        expect(subject).to have_css(".comment-thread")
        expect(subject).to have_content(comment.body.values.first)
        expect(subject).to have_no_css(".comment-reply")
        expect(subject).to have_css("[aria-label='Comment thread started by #{comment.author.name} on 01/02/2018 12:30']")
      end

      context "with replies" do
        let(:resource_locator) { Decidim::ResourceLocatorPresenter.new(commentable) }
        let!(:replies) { create_list(:comment, 10, commentable: comment) }

        before do
          allow(Decidim::ResourceLocatorPresenter).to receive(:new).and_return(resource_locator)
          allow(resource_locator).to receive(:path).and_return("/dummies")
        end

        it "renders the reply" do
          expect(subject).to have_css(".comment-reply .comment", count: 10)
          expect(subject).to have_css("[aria-label='Comment thread started by #{comment.author.name} on 01/02/2018 12:30']")
        end

        context "with a deleted user" do
          let(:user) { create(:user, :deleted, organization: component.organization) }
          let(:comment) { create(:comment, commentable:, author: user) }

          it "renders the user as deleted" do
            expect(subject).to have_css(".comment__header", text: "Deleted participant")
          end
        end
      end
    end
  end
end
