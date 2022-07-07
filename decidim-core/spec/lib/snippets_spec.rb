# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Snippets do
    describe "#add" do
      it "can add a single snippet" do
        subject.add(:foo, "|foo_snippet|")
        subject.add(:bar, "|bar_snippet|")
        expect(subject.for(:foo)).to eq(["|foo_snippet|"])
        expect(subject.for(:bar)).to eq(["|bar_snippet|"])
      end

      it "can add a multiple snippets" do
        subject.add(:foo, "|foo_snippet|", "|foo2_snippet|", "|foo3_snippet|")
        subject.add(:bar, "|bar_snippet|", "|bar2_snippet|")
        expect(subject.for(:foo)).to eq(["|foo_snippet|", "|foo2_snippet|", "|foo3_snippet|"])
        expect(subject.for(:bar)).to eq(["|bar_snippet|", "|bar2_snippet|"])
      end
    end

    describe "#for" do
      it "returns nil when there are no snippets" do
        expect(subject.for(:foo)).to be_nil
      end

      it "returns the snippets when they exist" do
        subject.add(:foo, "|foo_snippet|", "|foo2_snippet|", "|foo3_snippet|")
        expect(subject.for(:foo)).to eq(["|foo_snippet|", "|foo2_snippet|", "|foo3_snippet|"])
      end
    end

    describe "#any?" do
      it "returns false when there are no snippets" do
        expect(subject.any?(:foo)).to be(false)
      end

      it "returns true when there are snippets" do
        subject.add(:foo, "|foo_snippet|")
        expect(subject.any?(:foo)).to be(true)
      end
    end

    describe "#display" do
      it "returns nil when there are no snippets" do
        expect(subject.display(:foo)).to be_nil
      end

      it "returns the snippets joined with a new line when they exist" do
        subject.add(:foo, "|foo_snippet|", "|foo2_snippet|", "|foo3_snippet|")
        expect(subject.display(:foo)).to eq("|foo_snippet|\n|foo2_snippet|\n|foo3_snippet|")
      end

      it "marks the string as HTML safe" do
        subject.add(:foo, "|foo_snippet|")
        expect(subject.display(:foo).html_safe?).to be(true)
      end
    end
  end
end
