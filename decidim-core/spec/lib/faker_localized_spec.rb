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
        # The last locale can be a machine translated locale, so only test the
        # ones before that.
        test_locales = available_locales.length > 1 ? available_locales[0..-2] : available_locales
        test_locales.each do |locale|
          expect(subject[locale]).not_to be_nil
        end
      end
    end

    describe Localized do
      let(:available_locales) { [:en, :ca, :es] }

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

        describe "with machine translations" do
          subject do
            described_class.wrapped "<p>", "</p>" do
              {
                en: "foo",
                ca: "foo",
                machine_translations: {
                  es: "foo"
                }
              }
            end
          end

          it "wraps the text for each locale" do
            expect(subject[:en]).to eq "<p>foo</p>"
            expect(subject[:ca]).to eq "<p>foo</p>"
          end

          it "wraps the text for each machine translation" do
            expect(subject[:machine_translations][:es]).to eq "<p>foo</p>"
          end
        end
      end

      describe "localized" do
        subject do
          described_class.localized do
            "foo"
          end
        end

        it "wraps the text for each locale and the last locale as machine translated" do
          expect(subject[:en]).to eq "foo"
          expect(subject[:ca]).to eq "foo"
          expect(subject[:machine_translations][:es]).to eq "foo"
        end
      end

      describe "prefixed" do
        subject { described_class.prefixed("example text") }

        it "prefixes the msg with the corresponding locale and the last locale as machine translated" do
          expect(subject[:en]).to eq "EN: example text"
          expect(subject[:ca]).to eq "CA: example text"
          expect(subject[:machine_translations][:es]).to eq "ES: example text"
        end
      end

      context "with a single locale" do
        let(:available_locales) { [:en] }

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

          it "sets the text for the single locale" do
            expect(subject[:en]).to eq "foo"
          end
        end

        describe "wrapped" do
          subject do
            described_class.wrapped "<p>", "</p>" do
              { en: "foo" }
            end
          end

          it "wraps the text for the single locale" do
            expect(subject[:en]).to eq "<p>foo</p>"
          end
        end

        describe "localized" do
          subject do
            described_class.localized do
              "foo"
            end
          end

          it "wraps the text for the single locale" do
            expect(subject[:en]).to eq "foo"
          end

          it "does not generate machine translations" do
            expect(subject[:machine_translations]).to be_nil
          end
        end

        describe "prefixed" do
          subject { described_class.prefixed("example text") }

          it "prefixes the msg with the corresponding locale" do
            expect(subject[:en]).to eq "EN: example text"
          end

          it "does not generate machine translations" do
            expect(subject[:machine_translations]).to be_nil
          end
        end
      end
    end
  end
end
