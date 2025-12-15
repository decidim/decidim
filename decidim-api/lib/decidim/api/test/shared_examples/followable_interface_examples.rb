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

  describe "followers" do
    let!(:follow) { create(:follow, followable: model) }
    let(:query) { "{ followers { id } }" }

    it "includes the field" do
      expect(response["followers"]).to be_present
      expect(response["followers"]).to include({ "id" => model.reload.followers.first.id.to_s })
    end
  end
end
