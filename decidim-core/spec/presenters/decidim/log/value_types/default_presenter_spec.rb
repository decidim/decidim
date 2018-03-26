# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::ValueTypes::DefaultPresenter, type: :helper do
  subject { described_class.new(value, helper) }

  let(:value) { 123 }

  describe "#present" do
    it "returns the value as is" do
      expect(subject.present).to eq value
    end
  end
end
