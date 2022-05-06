# frozen_string_literal: true

require "spec_helper"

describe Decidim::HtmlTruncation do
  subject { described_class.new(text, options).perform }

  let(:options) do
    {
      max_length: max_length,
      tail: tail,
      count_tags: count_tags,
      count_tail: count_tail,
      tail_before_final_tag: tail_before_final_tag
    }
  end
  let(:max_length) { 30 }
  let(:tail) { "..." }
  let(:count_tags) { false }
  let(:count_tail) { false }
  let(:tail_before_final_tag) { false }
  let(:text) { ::Faker::Lorem.paragraph(sentence_count: 25) }

  describe "empty content" do
    let(:text) { "" }

    it "does not do anything" do
      expect(subject).to eq(text)
    end
  end

  describe "short content" do
    let(:max_length) { 100 }
    let(:texts) do
      [
        "Mauris sed libero.",
        'foo <a href="www.example.com">link</a> bar',
        "some <strong>text</strong> here",
        "<b><em>foo</em></b>"
      ]
    end

    it "does not get cut" do
      texts.each do |test_text|
        expect(described_class.new(test_text, options).perform).to eq(test_text.to_s)
      end
    end
  end

  describe "long string" do
    it "cuts text and adds tail" do
      expect(subject).to eq(text.truncate(max_length + tail.length, omission: options[:tail]).to_s)
    end
  end

  describe "count tail" do
    let(:count_tail) { true }

    it "countas tail" do
      expect(subject).to eq(text.truncate(max_length, omission: options[:tail]).to_s)
    end
  end

  describe "count tags" do
    let(:count_tags) { true }
    let(:max_length) { 22 }
    let(:text) { %(<strong class="foo">bar</strong>) }

    it "counts tags also" do
      expect(subject).to eq(%(<strong class="foo">ba#{tail}</strong>))
    end

    describe "content with tag name" do
      let(:text) { %(<div style="color: purple;" class="foo">div</div>) }

      it "cuts content" do
        expect(subject).to eq(%(<div style="color: purple;" class="foo">#{tail}</div>))
      end
    end

    describe "content with void element" do
      let(:text) { %(<img src="some/path/foo/bar" alt="foobar">text) }

      it "cuts content after the element" do
        expect(subject).to eq(%(<img src="some/path/foo/bar" alt="foobar">#{tail}))
      end
    end

    describe "sequential void elements" do
      let(:text) { %(<img src="some/path/foo/bar" alt="foobar"><input id="bar" type="text"><br>) }

      it "cuts between elements" do
        expect(subject).to eq(%(<img src="some/path/foo/bar" alt="foobar">#{tail}))
      end
    end
  end

  describe "tail before final tag" do
    let(:tail_before_final_tag) { true }
    let(:max_length) { 5 }
    let(:text) { %(<p>foo<strong class="bar">baz</strong></p>) }

    it "adds tail to the end" do
      expect(subject).to eq(%(<p>foo<strong class="bar">ba</strong>#{tail}</p>))
    end
  end

  describe "cut inside a tag" do
    let(:outer_before) { "foo " }
    let(:outer_after) { " bar" }
    let(:inner_text) { %(this is longer text than max length and is going to be cut) }
    let(:tags) do
      [
        { opening: %(<a href="www.example.org/something">), closing: %(</a>) },
        { opening: %(<strong>), closing: %(</strong>) },
        { opening: %(<em>), closing: %(</em>) },
        { opening: %(<span class="baz">), closing: %(</span>) }
      ]
    end

    it "cuts inner text of a tag" do
      tags.each do |tag|
        test_text = "#{outer_before}#{tag[:opening]}#{inner_text}#{tag[:closing]}#{outer_after}"
        truncate_length = max_length - outer_before.length + options[:tail].length
        expect(described_class.new(test_text, options).perform).to eq("#{outer_before}#{tag[:opening]}#{inner_text.truncate(truncate_length, omission: options[:tail])}#{tag[:closing]}")
      end
    end
  end

  describe "option max length" do
    let(:max_length) { 100 }

    it "cuts text after 100 characters, adds tail and wraps to p tag" do
      expect(subject).to eq(text.truncate(max_length + tail.length, omission: tail).to_s)
    end
  end

  describe "dont change quotation marks inside the tags" do
    let(:max_length) { 19 }
    let(:text) { %(<p>some <b>"content"</b> here, cut at comma") }

    it "changes escaped quotes" do
      expect(subject).to eq(%(<p>some <b>&quot;content&quot;</b> here#{tail}</p>))
    end
  end

  describe "nested tags" do
    let(:max_length) { 100 }
    let(:text) { "<p>Lorem <strong>ipsum <i>dolor</i> sit amet</strong>, consectetuer adipiscing elit.</p> <p>Sed posuere interdum sem. Quisque ligula <em>eros ullamcorper <strong>quis</strong>, lacinia</em> quis facilisis sed sapien.</p>" }

    it "cuts inside tags" do
      expect(subject).to eq(%(<p>Lorem <strong>ipsum <i>dolor</i> sit amet</strong>, consectetuer adipiscing elit.</p> <p>Sed posuere interdum sem. Quisque ligula <em>e#{tail}</em></p>))
    end
  end

  describe "HTML content with deeper elements" do
    let(:text) do
      %(
        <div>
          <article>
            <h2>Foo</h2>
            <div>
              <p>Lorem <strong>ipsum <i>dolor</i> sit amet</strong>, consectetuer adipiscing elit.</p>
              <p>Sed posuere interdum sem. Quisque ligula <em>eros ullamcorper <strong>quis</strong>, lacinia</em> quis facilisis sed sapien.</p>
              <p><a href="#">Read more</a></p>
            </div>
          </article>
        </div>
      ).gsub(/\s{2,}/, "").gsub("\n", "")
    end
    let(:expected) { %(<div><article><h2>Foo</h2><div><p>Lorem <strong>ipsum <i>dolor</i> sit amet</strong>, consectetuer adipiscing elit.</p><p>Sed posuere interdum sem. Quisque ligula <em>eros ullamcorper <strong>qu#{tail}</strong></em></p></div></article></div>) }
    let(:max_length) { 120 }

    it "cuts deep" do
      expect(subject).to eq(expected)
    end
  end
end
