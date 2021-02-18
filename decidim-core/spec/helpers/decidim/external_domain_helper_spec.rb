# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ExternalDomainHelper do
    let(:url) { Faker::Internet.url }

    context "when everything is OK" do
      it { expect(helper.highlight_domain("http://decidim.barcelona")).to include('class="alert">decidim.barcelona') }
    end

    context "when invalid URL" do
      it "raises InvalidUrlError" do
        expect { helper.highlight_domain(Faker::Internet.slug) }.to raise_error(Decidim::ExternalDomainHelper::InvalidUrlError)
      end
    end
  end
end
