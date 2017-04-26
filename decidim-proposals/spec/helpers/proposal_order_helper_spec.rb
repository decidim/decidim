# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Proposals
    describe ProposalOrderHelper do
      before do
        allow(helper).to receive(:current_settings).and_return(current_settings)
      end

      describe "#order_fields" do
        context "with votes enabled" do
          context "with votes hidden" do
            let(:current_settings) { double(:current_settings, { votes_enabled?: true, votes_hidden?: true }) }

            it "does not show most_voted option to sort" do
              expect(helper.order_fields).not_to include(:most_voted)
            end
          end

          context "with votes not hidden" do
            let(:current_settings) { double(:current_settings, { votes_enabled?: true, votes_hidden?: false }) }

            it "shows most_voted option to sort" do
              expect(helper.order_fields).to include(:most_voted)
            end
          end
        end

        context "with votes disabled" do
          let(:current_settings) { double(:current_settings, { votes_enabled?: false }) }

          it "doesn't show most_voted option to sort" do
            expect(helper.order_fields).not_to include(:most_voted)
          end
        end
      end
    end
  end
end
