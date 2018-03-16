# frozen_string_literal: true

require "spec_helper"

shared_examples_for "has component" do
  context "without a component" do
    before do
      subject.component = nil
    end

    it { is_expected.not_to be_valid }
  end

  context "without a valid component" do
    before do
      subject.component = build(:component, manifest_name: "foo-bar")
    end

    it { is_expected.not_to be_valid }
  end
end
