# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe WidgetUrlsHelper do
    let(:redesign_enabled) { false }

    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(ActionView::Base).to receive(:redesign_enabled?).and_return(redesign_enabled)
      # rubocop:enable RSpec/AnyInstance
    end

    describe "#embed_modal_for" do
      it "returns an escaped HTML string" do
        expect(helper.embed_modal_for("https://example.org"))
          .not_to match(%r{<script src=.*></script>})
      end
    end
  end
end
