# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Env do
    subject { described_class.new(name, default) }
    let(:name) { "TEST_ENV_VAR" }
    let(:value) { nil }
    let(:default) { nil }

    before do
      ENV[name] = value.to_s if name.present?
    end

    after do
      ENV.delete(name) if name.present?
    end

    shared_examples "a nil value" do
      it "returns nil" do
        expect(subject.value).to be_nil
        expect(subject.to_s).to eq("")
        expect(subject.to_i).to eq(0)
        expect(subject.to_json).to eq("null")
        expect(subject.blank?).to be(true)
        expect(subject.present?).to be(false)
        expect(subject.to_array).to eq([])
      end

      context "and has a default" do
        let(:default) { 42 }

        it "returns the default" do
          expect(subject.value).to eq(42)
          expect(subject.to_s).to eq("42")
          expect(subject.to_i).to eq(42)
          expect(subject.to_json).to eq("42")
          expect(subject.blank?).to be(false)
          expect(subject.present?).to be(true)
          expect(subject.to_array).to eq(["42"])
        end
      end
    end

    shared_examples "a defined value" do
      it "returns the value" do
        expect(subject.value).not_to be_nil
        expect(subject.value).to eq(value)
        expect(subject.to_s).not_to eq("")
        expect(subject.to_s).to eq(value.to_s)
        expect(subject.to_i).to eq(value.to_s.to_i)
        expect(subject.to_json).not_to eq("null")
        expect(subject.to_json).to eq(value.to_json)
        expect(subject.present?).to be(true)
        expect(subject.blank?).to be(false)
        expect(subject.to_array).to eq([value.to_s])
      end

      context "and has a default" do
        let(:default) { 42 }

        it "returns the default" do
          expect(subject.value).not_to eq(42)
          expect(subject.value).to eq(value)
          expect(subject.to_i).to eq(value.to_s.to_i)
          expect(subject.to_array).to eq([value.to_s])
        end
      end
    end

    shared_examples "a false value" do
      it "returns false" do
        expect(subject.value).to eq(value)
        expect(subject.to_s).to eq(value)
        expect(subject.to_i).to eq(0)
        expect(subject.to_json).to eq(value.to_json)
        expect(subject.blank?).to be(true)
        expect(subject.present?).to be(false)
      end

      context "and has a default" do
        let(:default) { 42 }

        it "the default is ignored" do
          expect(subject.value).to eq(value)
          expect(subject.to_s).to eq(value)
          expect(subject.to_json).to eq(value.to_json)
        end

        it "the default is applied" do
          expect(subject.to_i).to eq(42)
          expect(subject.blank?).to be(true)
          expect(subject.present?).to be(false)
        end
      end
    end

    shared_examples "default_or_present as boolean" do |present|
      it "behaves as present" do
        expect(subject.default_or_present_if_exists).to eq(present)
      end

      context "and has a default" do
        let(:default) { 42 }

        it "behaves as present" do
          expect(subject.default_or_present_if_exists).to eq(present)
        end
      end
    end

    shared_examples "default_or_present as default" do
      it "behaves as default" do
        expect(subject.default_or_present_if_exists).to be_nil
      end

      context "and has a default" do
        let(:default) { 42 }

        it "behaves as present" do
          expect(subject.default_or_present_if_exists).to eq(default)
        end
      end
    end

    shared_examples "empty array or default" do
      it "returns empty array" do
        expect(subject.to_array).to eq([])
      end

      context "and has a default" do
        let(:default) { "en,ca" }

        it "returns default as array" do
          expect(subject.to_array).to eq(%w(en ca))
        end
      end
    end

    describe "value" do
      context "when empty" do
        it_behaves_like "a nil value"
        it_behaves_like "default_or_present as boolean", false
      end

      context "when undefined" do
        let(:name) { "" }

        it_behaves_like "a nil value"
        it_behaves_like "default_or_present as default"
      end
    end

    context "when value" do
      let(:value) { "I know what I'm doing" }

      it_behaves_like "a defined value"
      it_behaves_like "default_or_present as boolean", true
    end

    context "when value is falsey" do
      describe "false" do
        let(:value) { "false" }

        it_behaves_like "a false value"
        it_behaves_like "default_or_present as boolean", false
      end

      describe "False" do
        let(:value) { "False" }

        it_behaves_like "a false value"
        it_behaves_like "default_or_present as boolean", false
      end

      describe "no" do
        let(:value) { "no" }

        it_behaves_like "a false value"
        it_behaves_like "default_or_present as boolean", false
      end

      describe "0" do
        let(:value) { "0" }

        it_behaves_like "a false value"
        it_behaves_like "default_or_present as boolean", false
      end
    end

    context "when value is an array" do
      let(:value) { "en, es, fr " }

      it "can convert to array using default separator" do
        expect(subject.to_array).to eq(%w(en es fr))
      end

      context "and customize separator" do
        let(:value) { "en,es, fr , ca " }

        it "can convert to array" do
          expect(subject.to_array(separator: ", ")).to eq(["en,es", "fr", "ca"])
        end
      end

      context "and value is falsey" do
        let(:value) { "False" }

        it_behaves_like "empty array or default"
      end
    end
  end
end
