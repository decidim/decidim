# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe WidgetUrlsHelper do
    describe "#embed_modal_for" do
      it "returns an escaped HTML string" do
        expect(helper.embed_modal_for("https://example.org"))
          .not_to match(%r{<script src=.*></script>})
      end
    end
  end
end
