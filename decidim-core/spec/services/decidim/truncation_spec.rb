# frozen_string_literal: true

require "spec_helper"

describe Decidim::Truncation do
  let(:subject) { described_class.new(text, options).truncate }
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

  describe "long string" do
    it "cuts text, adds tail and wraps to p tag" do
      expect(subject).to eq("<p>#{text.truncate(max_length + tail.length, omission: options[:tail])}</p>")
    end
  end

  describe "count tail" do
    let(:count_tail) { true }

    it "countas tail" do
      expect(subject).to eq("<p>#{text.truncate(max_length, omission: options[:tail])}</p>")
    end
  end

  describe "count tags" do
    let(:count_tags) { true }
    let(:max_length) { 22 }
    let(:text) { %(<strong class="foo">bar</strong) }

    it "counts tags also" do
      expect(subject).to eq('<p><strong class="foo">ba...</strong></p>')
    end
  end

  describe "tail before final tag" do
    let(:tail_before_final_tag) { true }
    let(:max_length) { 5 }
    let(:text) { %(<p>foo<strong class="bar">baz</strong></p>) }

    it "adds tail to the end" do
      expect(subject).to eq('<p><p>foo<strong class="bar">ba</strong>...</p></p>')
    end
  end

  describe "basic content" do
    let(:texts) do
      [
        "Mauris sed libero.",
        'foo <a href="www.example.com">link</a> bar',
        "some <strong>text</strong> here",
        "<b><em>foo</em></b>"
      ]
    end

    it "wraps text to p tag" do
      texts.each do |test_text|
        expect(described_class.new(test_text, options).truncate).to eq("<p>#{test_text}</p>")
      end
    end
  end

  describe "cut inside a tag" do
    let(:outer_before) { "foo " }
    let(:outer_after) { " bar" }
    let(:inner_text) { %(very long text here is this and its getting cutted</a> bar) }
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
        expect(described_class.new(test_text, options).truncate).to eq("<p>#{outer_before}#{tag[:opening]}#{inner_text.truncate(truncate_length, omission: options[:tail])}#{tag[:closing]}</p>")
      end
    end
  end

  describe "option max length" do
    let(:max_length) { 100 }

    it "cuts text after 100 characters, adds tail and wraps to p tag" do
      expect(subject).to eq("<p>#{text.truncate(max_length + tail.length, omission: tail)}</p>")
    end
  end
end
