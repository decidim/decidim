# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Comments
    describe CommentsHelper do
      class DummyCommentable
        def id
          1
        end
      end

      let(:commentable) { DummyCommentable.new }
        
      describe "comments_for" do
        it "should render the react component `Comments` with the correct data" do
          expect(helper)
            .to receive(:react_comments_component)
            .with("comments-for-DummyCommentable-1", {
              commentableType: "Decidim::Comments::DummyCommentable",
              commentableId: "1",
              options: {},
              locale: I18n.locale
            })
            .and_call_original

          helper.comments_for(commentable)
        end

        it "should accept an optional hash of options" do
          expect(helper)
            .to receive(:react_comments_component)
            .with("comments-for-DummyCommentable-1", {
              commentableType: "Decidim::Comments::DummyCommentable",
              commentableId: "1",
              options: {
                arguable: true
              },
              locale: I18n.locale
            })
            .and_call_original

          helper.comments_for(commentable, arguable: true)
        end
      end
    end
  end
end
