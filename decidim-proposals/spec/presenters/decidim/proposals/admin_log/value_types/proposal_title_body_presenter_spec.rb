# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::AdminLog::ValueTypes::ProposalTitleBodyPresenter do
  let(:value) do
    {
      "en" => "My value",
      "es" => "My title in Spanish"
    }
  end
  let(:_helpers) { nil }

  subject { described_class.new(value, _helpers) }

  describe "#present" do
    it "handles i18n fields" do
      expect(subject.present).to eq "My value"
    end
  end
end
