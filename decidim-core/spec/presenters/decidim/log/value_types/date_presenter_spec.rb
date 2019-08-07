# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::ValueTypes::DatePresenter, type: :helper do
  subject { described_class.new(value, helper) }

  let(:value) { Date.new(2018, 1, 2).at_midnight }

  describe "#present" do
    it "renders the value as a date" do
      expect(subject.present).to eq "January 02, 2018 00:00"
    end
  end
end
