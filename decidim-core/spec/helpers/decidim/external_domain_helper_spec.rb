# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ExternalDomainHelper do
    context "when everything is OK" do
      before { helper.instance_variable_set(:@url_parts, { protocol: "https:", domain: "decidim.barcelona", path: "/processes" }) }

      it "highlights domain" do
        expect(helper.highlight_domain).to include('class="alert">decidim.barcelona')
      end
    end
  end
end
