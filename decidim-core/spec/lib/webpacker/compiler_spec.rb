# frozen_string_literal: true

require "spec_helper"

module Webpacker
  describe Compiler do
    subject { described_class.new(webpacker) }

    let(:webpacker) { Webpacker.instance }

    describe "#fresh?" do
      before { subject.compile }

      it "allows multiple threads to fetch the status at the same time" do
        threads = []
        results = []
        10.times { threads << Thread.new { results << subject.fresh? } }
        threads.each(&:join)

        expect(results.length).to eq(10)
        expect(results.uniq).to match_array([true])
      end
    end
  end
end
