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
    let(:accept_language) { nil }
    let(:request) do
      double(
        env: { "decidim.current_organization" => organization, "warden" => double(user: warden_user), "HTTP_ACCEPT_LANGUAGE" => accept_language },
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
        it "returns the default locale even if I18n.locale is different" do
          I18n.with_locale(:es) do
            expect(subject.locale).to eq(default_locale)
          end
        end
      end

      context "when locale is provided via the Accept-Language header" do
        let(:accept_language) { "es" }

        it "returns the locale if it is available" do
          expect(subject.locale).to eq("es")
        end

        context "when the language is not available" do
          let(:accept_language) { "zz" }

          it "returns the default locale" do
            expect(subject.locale).to eq(default_locale)
          end
        end

        context "when the header contains a malicious payload" do
          let(:accept_language) { "<script>alert('xss')</script>" }

          it "returns the default locale" do
            expect(subject.locale).to eq(default_locale)
          end
        end

        context "when the user has a session locale" do
          let(:user_locale) { "ca" }

          it "prefers the session locale" do
            expect(subject.locale).to eq("ca")
          end
        end

        context "when the authenticated user has a locale" do
          let(:warden_user) { double(locale: "ca") }

          it "prefers the user locale" do
            expect(subject.locale).to eq("ca")
          end
        end

        context "when the locale is provided via input params" do
          let(:params) { { locale: "ca" } }

          it "prefers the input params locale" do
            expect(subject.locale).to eq("ca")
          end
        end
      end

      context "when the user is injected" do
        let(:warden_user) { double(locale: "ca") }

        it "uses the injected user locale instead of the authenticated user" do
          expect(described_class.new(request, params, user: double(locale: "es")).locale).to eq("es")
        end

        it "ignores the authenticated user when the injected user is nil" do
          expect(described_class.new(request, params, user: nil).locale).to eq(default_locale)
        end
      end

      context "when the organization is injected as nil" do
        let(:params) { { locale: "de" } }

        before do
          organization
          allow(Decidim).to receive(:available_locales).and_return(%w(en ca de))
        end

        it "uses the Decidim available locales" do
          expect(described_class.new(request, params, organization: nil).locale).to eq("de")
        end

        it "uses the organization available locales when not injected" do
          expect(subject.locale).to eq(default_locale)
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

        it "uses the default locale if everything else missing" do
          I18n.with_locale(:ca) do
            expect(described_class.new(request, {}).locale).to eq(default_locale)
          end
        end
      end
    end

    describe "#detected_locale" do
      it "returns nil when no locale is provided anywhere" do
        expect(subject.detected_locale).to be_nil
      end

      context "when the locale is not available" do
        let(:params) { { locale: "fr" } }

        it "returns nil" do
          expect(subject.detected_locale).to be_nil
        end
      end

      context "when the locale is available" do
        let(:params) { { locale: "es" } }

        it "returns the locale" do
          expect(subject.detected_locale).to eq("es")
        end
      end
    end

    describe "#accept_language_locale" do
      let(:available_locales) { %w(en ca pt-BR de de-CH) }

      before do
        allow(I18n.config).to receive(:enforce_available_locales).and_return(false)
      end

      {
        "ca" => "ca",
        "en" => "en",
        "pt-BR" => "pt-BR",
        "de-CH" => "de-CH",
        "pt-BR,ca,en" => "pt-BR",
        "zh,es,fr" => nil,
        "pt" => "pt-BR",
        "ca-ES" => "ca",
        "ca,pt-BR,en" => "ca",
        "es,en-US;q=0.8,ca;q=0.5,en;q=0.3" => "ca",
        "es,en-US;q=0.8,pt-BR;q=0.5,en;q=0.3" => "pt-BR",
        "es,en-US;q=0.1,pt-BR;q=0.5,en;q=0.6" => "en",
        "es, en-US;q=0.1, pt-BR;q=0.5, en" => "en",
        "de-CH;q=0.8, de;q=0.5" => "de-CH",
        "de-AT, de;q=0.5, de-CH;q=0.3" => "de",
        "*" => nil,
        "" => nil
      }.each do |header, expected|
        context "when the header is #{header.inspect}" do
          let(:accept_language) { header }

          it "returns #{expected.inspect}" do
            expect(subject.accept_language_locale).to eq(expected)
          end
        end
      end

      context "when there is no header" do
        it "returns nil" do
          expect(subject.accept_language_locale).to be_nil
        end
      end
    end
  end
end
