# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ApplicationController, type: :controller do
    let(:default_locale) { "en" }
    let(:alt_locale) { "pt-BR" }
    let(:available_locales) { %w(en ca pt-BR de de-CH) }
    let(:organization) { create(:organization, default_locale:) }

    before do
      allow(Decidim).to receive(:default_locale).and_return default_locale
      allow(Decidim).to receive(:available_locales).and_return available_locales
      allow(I18n.config).to receive(:enforce_available_locales).and_return(false)
    end

    describe "no locale is passed" do
      it "detected locale is empty" do
        expect(controller.detect_locale.to_s).to be_empty
      end

      it "application uses default language" do
        controller.switch_locale do
          expect(I18n.locale.to_s).to eq(default_locale)
        end
      end

      context "with alternate default locale" do
        let(:default_locale) { alt_locale }

        it "application uses organization's default language" do
          controller.switch_locale do
            expect(I18n.locale.to_s).to eq(alt_locale)
          end
        end
      end
    end

    context "with header Accept-Language" do
      headers = {
        "ca" => "ca",
        "en" => "en",
        "pt-BR" => "pt-BR",
        "de-CH" => "de-CH",
        "pt-BR,ca,en" => "pt-BR",
        "zh,es,fr" => nil,
        "pt" => "pt-BR",
        "ca-ES" => "ca", # RFC 2616 non-compliant
        "ca,pt-BR,en" => "ca",
        "es,en-US;q=0.8,ca;q=0.5,en;q=0.3" => "ca",
        "es,en-US;q=0.8,pt-BR;q=0.5,en;q=0.3" => "pt-BR",
        "es,en-US;q=0.1,pt-BR;q=0.5,en;q=0.6" => "en",
        "es, en-US;q=0.1, pt-BR;q=0.5, en" => "en",
        "de-CH;q=0.8, de;q=0.5" => "de-CH",
        "de-AT, de;q=0.5, de-CH;q=0.3" => "de"
      }
      headers.each do |string, lang|
        describe "header parser gives a supported language" do
          before do
            request.headers["Accept-Language"] = string
          end

          it "with default locale" do
            expect(controller.extract_locale_from_accept_language_header).to eq(lang)
          end
        end
      end
    end

    describe "request with unsupported language" do
      before do
        request.headers["Accept-Language"] = "zz"
      end

      it "locale is empty" do
        expect(controller.detect_locale.to_s).to be_empty
      end
    end

    describe "request with 5 chars a 2 chars supported language" do
      before do
        request.headers["Accept-Language"] = "ca-ES"
      end

      it "locale matches requested language" do
        expect(controller.detect_locale.to_s).to eq("ca")
      end
    end

    describe "request with 2 chars a 5 chars supported language" do
      before do
        request.headers["Accept-Language"] = "pt"
      end

      it "locale matches requested language" do
        expect(controller.detect_locale.to_s).to eq("pt-BR")
      end
    end

    describe "request with GET locale parameter" do
      before do
        request.headers["Accept-Language"] = "ca-ES"
        controller.params[:locale] = "de"
      end

      it "locale matches GET language" do
        expect(controller.detect_locale.to_s).to eq("de")
      end
    end

    describe "request with GET invalid locale parameter" do
      before do
        request.headers["Accept-Language"] = "ca-ES"
        controller.params[:locale] = "foo"
      end

      it "application uses default locale" do
        controller.switch_locale do
          expect(I18n.locale.to_s).to eq(default_locale)
        end
      end
    end

    describe "request with session defined language" do
      before do
        controller.session[:user_locale] = "ca"
      end

      it "application uses session language" do
        controller.switch_locale do
          expect(I18n.locale.to_s).to eq("ca")
        end
      end
    end

    describe "request with user session" do
      let(:user) { create(:user, :confirmed, locale: "de", organization:) }

      before do
        allow(controller).to receive(:current_user) { user }
        controller.session[:user_locale] = "ca"
      end

      it "application uses user language" do
        controller.switch_locale do
          expect(I18n.locale.to_s).to eq("de")
        end
      end
    end
  end
end
