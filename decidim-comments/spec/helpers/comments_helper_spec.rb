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
            .to receive(:react_component)
            .with("Comments", {
              commentableType: "Decidim::Comments::DummyCommentable",
              commentableId: "1",
              locale: I18n.locale
            })
            .and_call_original

          helper.comments_for(commentable)
        end
      end
    end
  end
end
