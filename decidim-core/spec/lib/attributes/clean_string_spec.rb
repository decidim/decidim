# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Attributes::CleanString do
    describe "#coerce" do
      subject { described_class.build(Attributes::CleanString, {}).coerce(value) }

      context "with long string with carriage returns" do
        let(:value) do
          [
            "This is a string with many carriage return characters and also \n",
            "some newlines without the carriage return.",
            "\r\n",
            "Using this string we\r test that the carriage return \n",
            "characters are stripped from the final result correctly.",
            "\r\r\n\r",
            "The carriage return characters are causing problems with the UI\n",
            "interacting with the backend, so we want to 'standardize' them \n",
            "to a common format so that the string length calculations are \n",
            "working consistently between the UI and the backend.\r"
          ].join
        end

        it "returns the date" do
          expect(subject).to eq(value.gsub(/\r/, ""))
        end
      end
    end
  end
end
