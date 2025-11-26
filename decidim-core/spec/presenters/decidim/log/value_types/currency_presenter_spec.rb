# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::ValueTypes::CurrencyPresenter, type: :helper do
  subject { described_class.new(value, helper) }

  let(:value) { 1123.4 }

  describe "#present" do
    it "renders the value as a currency" do
      expect(subject.present).to eq "€ 1,123.40"
    end
  end
end
