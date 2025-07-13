# frozen_string_literal: true

require "spec_helper"

shared_examples_for "followable interface" do
  describe "follows_count" do
    let(:query) { "{ followsCount }" }

    it "includes the field" do
      expect(response["followsCount"]).to eq(model.follows_count)
    end
  end
end
