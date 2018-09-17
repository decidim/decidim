# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Attributes::LocalizedDate do
    describe "coerce" do
      subject { described_class.build(Attributes::LocalizedDate, {}).coerce(value) }

      context "when given a Date" do
        let(:value) { Date.current }

        it "returns the date" do
          expect(subject).to eq(value)
        end
      end

      context "when given a String" do
        context "with the correct format" do
          let(:value) { "27 :> 12 () 2000 !!" }

          around do |example|
            I18n.available_locales += ["fake_locale"]

            I18n.backend.store_translations(:fake_locale, date: { formats: { decidim_short: "%d :> %m () %Y !!" } })

            I18n.with_locale(:fake_locale) do
              example.run
            end

            I18n.available_locales -= ["fake_locale"]
          end

          it "parses the String in the correct format" do
            expect(subject).to eq(Date.new(2000, 12, 27))
          end
        end

        context "with an incorrect format" do
          let(:value) { "foo" }

          it "returns nil" do
            expect(subject).to eq(nil)
          end
        end
      end
    end
  end
end
