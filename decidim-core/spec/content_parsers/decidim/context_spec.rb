# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentParsers::Context do
    subject { described_class.new(current_organization: organization) }

    let(:organization) { build(:organization) }

    describe "#initialize" do
      it "sets the value for passed attributes" do
        expect(subject.current_organization).to eq(organization)
      end
    end
  end
end
