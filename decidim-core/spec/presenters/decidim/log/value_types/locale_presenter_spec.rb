# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::ValueTypes::LocalePresenter, type: :helper do
  subject { described_class.new(value, helper) }

  let(:value) { "en" }

  describe "#present" do
    it "renders the value as a locale" do
      expect(subject.present).to eq "English"
    end
  end
end
