# frozen_string_literal: true

require "spec_helper"

shared_examples_for "timestamps interface" do
  describe "createdAt" do
    let(:query) { "{ createdAt }" }

    it "returns when was this query created at" do
      expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
    end
  end

  describe "updatedAt" do
    let(:query) { "{ updatedAt }" }

    it "returns when was this query updated at" do
      expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
    end
  end
end
