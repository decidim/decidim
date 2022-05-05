# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Fingerprintable do
    let(:klass) do
      Class.new do
        include Decidim::Fingerprintable

        def title
          "A title"
        end

        def body
          { en: "Body", ca: "Cos" }
        end
      end
    end

    subject { klass.new }

    context "when provided with fields" do
      before do
        klass.fingerprint fields: [:title, :body]
      end

      describe "#fingerprint" do
        it "returns a fingerprint calculator with the appropiate data" do
          fingerprint = subject.fingerprint
          expect(fingerprint.value.length).to be_positive
          expect(fingerprint.source).to eq("{\"body\":{\"ca\":\"Cos\",\"en\":\"Body\"},\"title\":\"A title\"}")
        end
      end
    end

    context "when provided with a block" do
      before do
        klass.fingerprint do |model|
          { title: model.title, body: model.body[:en] }
        end
      end

      describe "#fingerprint" do
        it "returns a fingerprint calculator with the appropiate data" do
          fingerprint = subject.fingerprint
          expect(fingerprint.value.length).to be_positive
          expect(fingerprint.source).to eq("{\"body\":\"Body\",\"title\":\"A title\"}")
        end
      end
    end
  end
end
