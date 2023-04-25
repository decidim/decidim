# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ExternalDomainHelper do
    context "when everything is OK" do
      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(ActionView::Base).to receive(:external_url).and_return(URI.parse("https://decidim.barcelona/processes"))
        # rubocop:enable RSpec/AnyInstance
      end

      it "highlights domain" do
        expect(helper.highlight_domain).to include('class="text-alert">decidim.barcelona')
      end
    end
  end
end
