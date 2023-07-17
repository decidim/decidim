# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Ai
    describe StrategyRegistry do
      subject { described_class.new }

      describe "register_analyzer" do
        it "registers a content block" do
          subject.register_analyzer(:dummy, Decidim::Ai::SpamContent::BaseStrategy)

          expect(subject.for(:dummy)).to be_a(Decidim::Ai::SpamContent::BaseStrategy)
        end

        it "raises an error if the content block is already registered" do
          subject.register_analyzer(:dummy, Decidim::Ai::SpamContent::BaseStrategy)

          expect { subject.register_analyzer(:dummy, Decidim::Ai::SpamContent::BaseStrategy) }
            .to raise_error(described_class::StrategyAlreadyRegistered)
        end
      end

      describe "for(:scope)" do
        it "returns all content blocks for that scope" do
          subject.register_analyzer(:dummy, Decidim::Ai::SpamContent::BaseStrategy)

          expect(subject.for(:dummy)).to be_a(Decidim::Ai::SpamContent::BaseStrategy)
        end
      end

      describe "all" do
        it "returns all content blocks" do
          subject.register_analyzer(:dummy, Decidim::Ai::SpamContent::BaseStrategy)

          expect(subject.all).to be_a(Hash)
          expect(subject.all.size).to be(1)
        end
      end
    end
  end
end
