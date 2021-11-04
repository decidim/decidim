# frozen_string_literal: true

require "spec_helper"

describe Decidim::Truncation do
  let(:subject) { described_class.new }
  let(:options) do
    {
      max_length: max_length,
      tail: tail,
      count_tags: count_tags,
      count_tail: count_tail,
      tail_before_final_tag: tail_before_final_tag
    }
  end
  let(:max_length) { 50 }
  let(:tail) { "..." }
  let(:count_tags) { false }
  let(:count_tail) { false }
  let(:tail_before_final_tag) { false }

  describe "long string" do
    let(:text) { "我的思想造就了我，我的大腦認為我要離開去唱歌，我要聽寫，我的家人要撒鹽，我的物種要唱歌。 話在我嘴裡融化，演講掉下來，我的舌頭抬起來，我的牙齒壞了。親愛的哥哥，我的婊子，我美麗的植物夥伴！" }

    it "cuts text, adds tail and wraps to p tag" do
      expect(described_class.new.truncate(text, options)).to eq("<p>#{text.truncate(50, omission: tail)}</p>")
    end
  end

  describe "basic texts" do
    let(:texts) do
      [
        "Mauris sed libero. Suspendisse facilisis nulla in lacinia laoreet.",
        'foo <a href="www.example.com">link</a> bar',
        "some <strong>text</strong> here",
        "<b><em>foo</em></b>"
      ]
    end

    it "wraps text to p tag" do
      texts.each do |test_text|
        expect(described_class.new.truncate(test_text, options)).to eq("<p>#{test_text}</p>")
      end
    end
  end
end
