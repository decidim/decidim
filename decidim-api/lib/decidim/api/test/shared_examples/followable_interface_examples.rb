# frozen_string_literal: true

require "spec_helper"

shared_examples_for "followable interface" do
  describe "follows_count" do
    let!(:follow) { create(:follow, followable: model) }
    let(:query) { "{ followsCount }" }

    it "includes the field" do
      expect(response["followsCount"]).to eq(model.reload.follows_count)
    end
  end
end
