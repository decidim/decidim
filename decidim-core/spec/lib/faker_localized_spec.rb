# frozen_string_literal: true

require "spec_helper"
require "decidim/faker/localized"

module Decidim
  module Faker
    shared_examples "a localized Faker method" do |method, *args|
      subject do
        if args
          described_class.public_send(method, *args)
        else
          described_class.public_send(method)
        end
      end

      it "has a value for each locale" do
        expect(subject[:en]).to be
        expect(subject[:ca]).to be
      end
    end

    describe Localized do
      let(:available_locales) { [:en, :ca] }

      before do
        allow(Decidim).to receive(:available_locales).and_return available_locales
      end

      it_behaves_like "a localized Faker method", :name
      it_behaves_like "a localized Faker method", :company
      it_behaves_like "a localized Faker method", :word
      it_behaves_like "a localized Faker method", :words
      it_behaves_like "a localized Faker method", :character
      it_behaves_like "a localized Faker method", :characters
      it_behaves_like "a localized Faker method", :sentence
      it_behaves_like "a localized Faker method", :sentences
      it_behaves_like "a localized Faker method", :paragraph
      it_behaves_like "a localized Faker method", :paragraphs
      it_behaves_like "a localized Faker method", :question
      it_behaves_like "a localized Faker method", :questions
      it_behaves_like "a localized Faker method", :literal, "foo"

      describe "literal" do
        subject { described_class.literal "foo" }

        it "sets the same text for all locales" do
          expect(subject[:en]).to eq "foo"
          expect(subject[:ca]).to eq "foo"
        end
      end

      describe "wrapped" do
        subject do
          described_class.wrapped "<p>", "</p>" do
            {
              en: "foo",
              ca: "foo"
            }
          end
        end

        it "wraps the text for each locale" do
          expect(subject[:en]).to eq "<p>foo</p>"
          expect(subject[:ca]).to eq "<p>foo</p>"
        end
      end
    end
  end
end
