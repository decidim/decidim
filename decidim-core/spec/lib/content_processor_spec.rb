# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentProcessor do
    before do
      allow(Decidim).to receive(:content_processors).and_return([:dummy_foo, :dummy_bar])
    end

    let(:processor) { ContentProcessor }
    let(:initial_text) { "This text contains foo and bar and another foo" }
    let(:final_text) { "This text contains _foo_ and _bar_ and another _foo_" }

    describe "#parse" do
      subject { processor.parse(initial_text) }

      it "executes all registered parsers" do
        expect(subject.rewrite).to eq(final_text)
        expect(subject.metadata).to eq(dummy_foo: 2, dummy_bar: 1)
      end
    end

    describe "#render" do
      subject { processor.render(final_text) }

      it "executes all registered parsers" do
        expect(subject).to eq(initial_text)
      end
    end
  end
end
