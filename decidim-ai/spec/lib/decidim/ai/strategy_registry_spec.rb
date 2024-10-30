# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ai
    describe StrategyRegistry do
      subject { described_class.new }

      let(:analyzer) { { name: :dummy, strategy: Decidim::Ai::SpamDetection::Strategy::Base } }

      describe "register_analyzer" do
        it "registers a content block" do
          subject.register_analyzer(**analyzer)

          expect(subject.for(:dummy)).to be_a(Decidim::Ai::SpamDetection::Strategy::Base)
        end

        it "raises an error if the content block is already registered" do
          subject.register_analyzer(**analyzer)

          expect { subject.register_analyzer(**analyzer) }
            .to raise_error(described_class::StrategyAlreadyRegistered)
        end
      end

      describe "for(:scope)" do
        it "returns all content blocks for that scope" do
          subject.register_analyzer(**analyzer)

          expect(subject.for(:dummy)).to be_a(Decidim::Ai::SpamDetection::Strategy::Base)
        end
      end

      describe "all" do
        it "returns all content blocks" do
          subject.register_analyzer(**analyzer)

          expect(subject.strategies).to be_a(Array)
          expect(subject.size).to be(1)
        end
      end
    end
  end
end
