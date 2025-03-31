# frozen_string_literal: true

require "spec_helper"

shared_examples_for "referable interface" do
  describe "reference" do
    let(:query) { "{ reference }" }

    it "includes the field" do
      expect(response["reference"]).to eq(model.reference.to_s)
    end
  end
end
