# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::AdminLog::ValueTypes::ProposalTitleBodyPresenter, type: :helper do
  subject { described_class.new(value, helper) }

  before do
    module FooBar
      include Decidim::SanitizeHelper
    end

    helper.extend FooBar
  end

  let(:value) do
    {
      "en" => "My value",
      "es" => "My title in Spanish"
    }
  end

  describe "#present" do
    it "handles i18n fields" do
      expect(subject.present).to eq "My value"
    end
  end
end
