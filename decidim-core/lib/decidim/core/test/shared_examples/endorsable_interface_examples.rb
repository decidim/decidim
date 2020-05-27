# frozen_string_literal: true

require "spec_helper"

shared_examples_for "endorsable interface" do
  describe "endorsementsCount" do
    let(:query) { "{ endorsementsCount }" }

    it "returns the amount of endorsements for this query" do
      expect(response["endorsementsCount"]).to eq(model.endorsements.count)
    end
  end

  describe "endorsements" do
    let(:query) { "{ endorsements { name } }" }

    it "returns the endorsements this query has received" do
      endorsement_names = response["endorsements"].map { |endorsement| endorsement["name"] }
      expect(endorsement_names).to include(*model.endorsements.map(&:author).map(&:name))
    end
  end
end
