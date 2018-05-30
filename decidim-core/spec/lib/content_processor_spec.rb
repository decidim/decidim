# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentProcessor do
    before do
      allow(Decidim).to receive(:content_processors).and_return([:dummy_foo, :dummy_bar])
    end

    let(:context) { {} }
    let(:processor) { ContentProcessor }

    describe "#parse" do
      subject { processor.parse("This text contains foo and bar and another foo", context) }

      it "executes all registered parsers" do
        expect(subject.rewrite).to eq("This text contains *lorem* and *ipsum* and another *lorem*")
        expect(subject.metadata).to eq(dummy_foo: 2, dummy_bar: 1)
      end
    end

    describe "#render" do
      subject { processor.render("This text contains *lorem* and *ipsum* and another *lorem*") }

      it "executes all registered parsers" do
        expect(subject).to eq("<p>This text contains <em>neque dicta enim quasi</em> and <em>illo qui voluptas</em> and another <em>neque dicta enim quasi</em></p>")
      end
    end
  end
end
