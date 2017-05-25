# frozen_string_literal: true

require "spec_helper"

shared_examples_for "has feature" do
  context "without a feature" do
    before do
      subject.feature = nil
    end

    it { is_expected.not_to be_valid }
  end

  context "without a valid feature" do
    before do
      subject.feature = build(:feature, manifest_name: "foo-bar")
    end

    it { is_expected.not_to be_valid }
  end
end
