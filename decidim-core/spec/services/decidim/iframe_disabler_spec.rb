# frozen_string_literal: true

require "spec_helper"

describe Decidim::IframeDisabler do
  let(:disabler) { described_class.new(text, {}) }

  describe "#perform" do
    subject { disabler.perform }

    let(:iframe) { %(<iframe class="testing" src="https://www.youtube.com/embed/f6JMgJAQ2tc" title="Decidim video" allowfullscreen></iframe>) }

    context "when the text is an iframe" do
      let(:text) { iframe }

      it "converts the iframe to a disabled div element" do
        expect(subject).to eq(
          %(<div class="disabled-iframe"><!-- #{text} --></div>)
        )
      end
    end

    context "when the iframe is a sub-node" do
      let(:text) { %(<div><div>#{iframe}</div></div>) }

      it "converts the iframe to a disabled div element" do
        expect(subject).to eq(
          %(<div><div><div class="disabled-iframe"><!-- #{iframe} --></div></div></div>)
        )
      end
    end
  end
end
