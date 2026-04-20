# frozen_string_literal: true

require "spec_helper"

describe Decidim::Routes::LocaleRedirects do
  let(:routes) do
    Class.new do
      extend Decidim::Routes::LocaleRedirects
    end
  end

  before do
    allow(Decidim::LocaleRouterDetector).to receive(:new).and_return(instance_double("Detector", locale: "es"))
  end

  describe "#locale_redirect" do
    it "builds locale scope options" do
      expect(routes.locale_scope_options).to eq(
        defaults: { locale: Decidim.default_locale },
        constraints: { locale: Regexp.union(I18n.available_locales.map(&:to_s)) }
      )
    end

    it "builds a locale-aware path" do
      request = instance_double("Request", query_string: "")

      allow(Decidim::LocaleRouterDetector).to receive(:new).and_return(instance_double("Detector", locale: "es"))

      expect(routes.locale_redirect({}, request, "/pages")).to eq("/es/pages")
    end

    it "preserves query strings by default" do
      request = instance_double("Request", query_string: "share_token=FOOBAR")

      allow(Decidim::LocaleRouterDetector).to receive(:new).and_return(instance_double("Detector", locale: "en"))

      expect(routes.locale_redirect({}, request, "/assemblies/laser-doctor")).to eq("/en/assemblies/laser-doctor?share_token=FOOBAR")
    end

    it "returns a redirect callable" do
      expect(routes.locale_redirector("/pages")).to respond_to(:call)
    end

    it "preserves query strings when requested" do
      request = instance_double("Request", query_string: "filter[term]=foo&locale=ca")

      allow(Decidim::LocaleRouterDetector).to receive(:new).and_return(instance_double("Detector", locale: "en"))

      expect(routes.locale_redirect({}, request, "/search", preserve_query_string: true)).to eq("/en/search?filter[term]=foo")
    end

    it "keeps 404 paths untouched" do
      request = instance_double("Request", query_string: "")

      allow(Decidim::LocaleRouterDetector).to receive(:new).and_return(instance_double("Detector", locale: "ca"))

      expect(routes.locale_redirect({}, request, "/404")).to eq("/404")
    end
  end
end
