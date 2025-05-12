# frozen_string_literal: true

require "spec_helper"

shared_examples_for "likeable interface" do
  describe "likesCount" do
    let(:query) { "{ likesCount }" }

    it "returns the amount of likes for this query" do
      expect(response["likesCount"]).to eq(model.likes.count)
    end
  end

  describe "likes" do
    let(:query) { "{ likes { name } }" }

    it "returns the likes this query has received" do
      like_names = response["likes"].map { |like| like["name"] }
      expect(like_names).to include(*model.likes.map(&:author).map(&:name))
    end
  end
end
