# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe LocaleRouterDetector do
    subject { described_class.new(request, params) }
    let(:organization) { create(:organization, default_locale:, available_locales:) }

    let(:params) { {} }
    let(:locale) { "" }
    let(:user_locale) { "" }
    let(:session) { { user_locale: } }
    let(:parameters) { { locale: } }
    let(:warden_user) { nil }
    let(:request) do
      double(
        env: { "decidim.current_organization" => organization, "warden" => double(user: warden_user) },
        session:,
        parameters: { locale: }
      )
    end
    let(:available_locales) { %w(en es ca) }
    let(:default_locale) { "en" }

    before do
      allow(Decidim).to receive(:available_locales).and_return(available_locales)
      allow(Decidim).to receive(:default_locale).and_return(default_locale)
    end

    around do |example|
      I18n.with_locale(I18n.locale) do
        example.run
      end
    end

    describe "#locale" do
      context "when the default locale is not english" do
        let(:default_locale) { "es" }

        context "when the locale is not available" do
          let(:params) { { locale: "fr" } }

          it "returns the default locale" do
            expect(subject.locale).to eq(default_locale)
          end
        end
      end

      context "when locale is provided via input params" do
        let(:params) { { locale: "es" } }

        it "returns the locale if it is available" do
          expect(subject.locale).to eq("es")
        end

        context "when the locale has an invalid format" do
          let(:params) { { locale: "fr-ca" } }

          it "returns the default locale" do
            expect(subject.locale).to eq(default_locale)
          end
        end

        context "when the locale is not available" do
          let(:params) { { locale: "fr" } }

          it "returns the default locale" do
            expect(subject.locale).to eq(default_locale)
          end
        end

        context "when locale is a symbol" do
          let(:params) { { locale: :ca } }

          it "accepts and returns it (string or symbol is fine; method returns extracted value)" do
            expect(subject.locale).to eq(:ca)
          end
        end
      end

      context "when locale is provided via request parameters" do
        let(:locale) { "ca" }

        it "returns the locale if it is available" do
          expect(subject.locale).to eq("ca")
        end

        context "when the locale is not available" do
          let(:locale) { "fr" }

          it "returns the default locale" do
            expect(subject.locale).to eq(default_locale)
          end
        end
      end

      context "when locale is provided via session user_locale" do
        let(:user_locale) { "es" }

        it "returns the locale if it is available" do
          expect(subject.locale).to eq("es")
        end

        context "when the locale is not available" do
          let(:user_locale) { "fr" }

          it "returns the default locale" do
            expect(subject.locale).to eq(default_locale)
          end
        end
      end

      context "when locale is provided via the authenticated user" do
        let(:warden_user) { double(locale: "ca") }

        it "returns the locale if it is available" do
          expect(subject.locale).to eq("ca")
        end

        context "when the locale is not available" do
          let(:warden_user) { double(locale: "fr") }

          it "returns the default locale" do
            expect(subject.locale).to eq(default_locale)
          end
        end
      end

      context "when no locale is provided anywhere" do
        it "falls back to I18n.locale if it is available" do
          I18n.with_locale(:es) do
            expect(subject.locale).to eq(:es)
          end
        end
      end

      context "when has a precedence order" do
        it "prefers input params over request parameters over session over I18n.locale" do
          I18n.with_locale(:en) do
            request.session[:user_locale] = "ca"
            request.parameters[:locale] = "es"

            # input params wins
            expect(described_class.new(request, { locale: "en" }).locale).to eq(default_locale)
          end
        end

        it "uses request parameters if input params missing" do
          I18n.with_locale(:en) do
            request.session[:user_locale] = "ca"
            request.parameters[:locale] = "es"

            expect(described_class.new(request, {}).locale).to eq("es")
          end
        end

        it "uses session if input params and request parameters missing" do
          I18n.with_locale(:en) do
            request.session[:user_locale] = "ca"

            expect(described_class.new(request, {}).locale).to eq("ca")
          end
        end

        it "uses I18n.locale if everything else missing" do
          I18n.with_locale(:ca) do
            expect(described_class.new(request, {}).locale).to eq(:ca)
          end
        end
      end
    end
  end
end
