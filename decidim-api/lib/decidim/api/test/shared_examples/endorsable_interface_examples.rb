# frozen_string_literal: true

require "spec_helper"

shared_examples_for "likable interface" do
  describe "endorsementsCount" do
    let(:query) { "{ endorsementsCount }" }

    it "returns the amount of likes for this query" do
      expect(response["endorsementsCount"]).to eq(model.likes.count)
    end
  end

  describe "likes" do
    let(:query) { "{ likes { name } }" }

    it "returns the likes this query has received" do
      endorsement_names = response["likes"].map { |like| like["name"] }
      expect(endorsement_names).to include(*model.likes.map(&:author).map(&:name))
    end
  end
end
