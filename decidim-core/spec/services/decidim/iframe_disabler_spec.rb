# frozen_string_literal: true

require "spec_helper"

describe Decidim::IframeDisabler do
  let(:disabler) { described_class.new(text, {}) }

  describe "#perform" do
    subject { disabler.perform }

    let(:iframe) { %(<iframe class="testing" src="https://www.youtube.com/embed/f6JMgJAQ2tc" title="Decidim video" allowfullscreen scrolling="no"></iframe>) }

    context "when the text is an iframe" do
      let(:text) { iframe }

      it "converts the iframe to a disabled div element" do
        expect(subject).to eq(
          %(<div class="disabled-iframe"><!-- <iframe class="testing" src="https://www.youtube-nocookie.com/embed/f6JMgJAQ2tc" title="Decidim video" allowfullscreen scrolling="no"></iframe> --></div>)
        )
      end
    end

    context "when the iframe does not define the scrolling attribute" do
      let(:iframe) { %(<iframe src="https://www.youtube.com/embed/f6JMgJAQ2tc" title="Decidim video"></iframe>) }
      let(:text) { iframe }

      it "adds the scrolling attribute to the iframe node" do
        expect(subject).to eq(
          %(<div class="disabled-iframe"><!-- <iframe src="https://www.youtube-nocookie.com/embed/f6JMgJAQ2tc" title="Decidim video" scrolling="no"></iframe> --></div>)
        )
      end
    end

    context "when the iframe does not define the title attribute" do
      let(:iframe) { %(<iframe src="https://www.youtube.com/embed/f6JMgJAQ2tc" scrolling="no"></iframe>) }
      let(:text) { iframe }

      it "adds the default title to the iframe node" do
        expect(subject).to eq(
          %(<div class="disabled-iframe"><!-- <iframe src="https://www.youtube-nocookie.com/embed/f6JMgJAQ2tc" scrolling="no" title="Embedded video content"></iframe> --></div>)
        )
      end
    end

    context "when the iframe's title attribute is empty" do
      let(:iframe) { %(<iframe src="https://www.youtube.com/embed/f6JMgJAQ2tc" title="" scrolling="no"></iframe>) }
      let(:text) { iframe }

      it "adds the default title to the iframe node" do
        expect(subject).to eq(
          %(<div class="disabled-iframe"><!-- <iframe src="https://www.youtube-nocookie.com/embed/f6JMgJAQ2tc" title="Embedded video content" scrolling="no"></iframe> --></div>)
        )
      end
    end

    context "when the iframe is a sub-node" do
      let(:text) { %(<div><div>#{iframe}</div></div>) }

      it "converts the iframe to a disabled div element" do
        expect(subject).to eq(
          %(<div><div><div class="disabled-iframe"><!-- <iframe class="testing" src="https://www.youtube-nocookie.com/embed/f6JMgJAQ2tc" title="Decidim video" allowfullscreen scrolling="no"></iframe> --></div></div></div>)
        )
      end
    end

    context "when the iframe source contains an embed code" do
      let(:iframe) { %(<iframe src="&lt;iframe width=&quot;560&quot; height=&quot;315&quot; src=&quot;https://www.youtube.com/embed/y8CcxALf4PQ&quot; title=&quot;YouTube video player&quot; frameborder=&quot;0&quot; allowfullscreen&gt;&lt;/iframe&gt;" title="video url"></iframe>) }
      let(:text) { iframe }

      it "extracts the embed URL from the source" do
        expect(subject).to eq(
          %(<div class="disabled-iframe"><!-- <iframe src="https://www.youtube-nocookie.com/embed/y8CcxALf4PQ" title="video url" scrolling="no"></iframe> --></div>)
        )
      end
    end
  end
end
