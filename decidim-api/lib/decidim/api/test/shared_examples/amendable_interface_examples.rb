# frozen_string_literal: true

require "spec_helper"

shared_examples_for "amendable interface" do
  describe "amendments" do
    let(:query) { "{ amendments { id } }" }

    it "includes the amendments id" do
      amendments_ids = response["amendments"].map { |amendment| amendment["id"].to_i }
      expect(amendments_ids).to include(*model.amendments.map(&:id))
    end
  end
end
