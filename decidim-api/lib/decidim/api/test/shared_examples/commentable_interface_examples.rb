# frozen_string_literal: true

require "spec_helper"

shared_examples_for "commentable interface" do
  describe "total_comments_count" do
    let(:query) { "{ totalCommentsCount }" }

    it "includes the field" do
      expect(response["totalCommentsCount"]).to eq(model.comments_count)
    end
  end
end
