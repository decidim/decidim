# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentsHelper do
      let(:dummy_resource) { create(:dummy_resource) }

      describe "comments_for" do
        it "should render the react component `Comments` with the correct data" do
          expect(helper)
            .to receive(:react_comments_component)
            .with(
              "comments-for-DummyResource-1",
              commentableType: "Decidim::DummyResource",
              commentableId: "1",
              locale: I18n.locale
            ).and_call_original

          helper.comments_for(dummy_resource)
        end
      end
    end
  end
end
