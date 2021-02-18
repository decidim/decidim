# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ExternalDomainHelper do
    context "when everything is OK" do
      it { expect(helper.highlight_domain("http://decidim.barcelona")).to include('class="alert">decidim.barcelona') }
    end

    context "when invalid URL" do
      let(:invalid_url) { "foo" }

      it "raises InvalidUrlError" do
        expect { helper.highlight_domain(invalid_url) }.to raise_error(Decidim::InvalidUrlError)
      end
    end
  end
end
