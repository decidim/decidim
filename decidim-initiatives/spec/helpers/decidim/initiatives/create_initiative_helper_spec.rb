# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe CreateInitiativeHelper do
      let(:online) { %w(OnLine online) }
      let(:offline) { ["Face to face", "offline"] }

      context "when online_signature_type_options" do
        it "contains online signature type options" do
          expect(helper.online_signature_type_options).to include(online)
          expect(helper.online_signature_type_options).not_to include(offline)
        end
      end

      context "when offline_signature_type_options" do
        it "contains offline signature type options" do
          expect(helper.offline_signature_type_options).not_to include(online)
          expect(helper.offline_signature_type_options).to include(offline)
        end
      end
    end
  end
end
