# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::ValueTypes::PercentagePresenter, type: :helper do
  subject { described_class.new(value, helper) }

  let(:value) { 12.5000 }

  describe "#present" do
    it "renders the value as a percentage" do
      expect(subject.present).to eq "12.5%"
    end
  end
end
