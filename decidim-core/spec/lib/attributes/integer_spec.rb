# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Attributes::Integer do
    describe "#cast" do
      subject { described_class.new.cast(value) }

      context "with a value responding to :id" do
        let(:value) { double }
        let(:id_value) { 123 }

        before do
          allow(value).to receive(:id).and_return(id_value)
        end

        it "returns the id of the value" do
          expect(subject).to eq(123)
        end

        context "when the id method returns a string" do
          let(:id_value) { "abc-123" }

          it "returns the id of the value as string" do
            expect(subject).to eq("abc-123")
          end
        end
      end
    end
  end
end
