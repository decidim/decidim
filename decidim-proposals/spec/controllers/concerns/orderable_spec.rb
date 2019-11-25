# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    class OrderableFakeController < Decidim::ApplicationController
      include Orderable
    end

    describe OrderableFakeController, type: :controller do
      let(:component_settings) { double(comments_enabled?: comments_enabled) }
      let(:comments_enabled) { nil }
      let(:current_settings) do
        double(:current_settings,
               votes_enabled?: votes_enabled,
               votes_hidden?: votes_hidden,
               endorsements_enabled?: endorsements_enabled)
      end
      let(:votes_enabled) { nil }
      let(:votes_hidden) { nil }
      let(:endorsements_enabled) { nil }
      let(:view) { controller.view_context }

      before do
        allow(controller).to receive(:component_settings).and_return(component_settings)
        allow(controller).to receive(:current_settings).and_return(current_settings)
      end

      describe "#available_orders" do
        context "with votes enabled" do
          let(:votes_enabled) { true }

          context "with votes hidden" do
            let(:votes_hidden) { true }

            it "does not show most_voted option to sort" do
              expect(view.available_orders).not_to include("most_voted")
            end
          end

          context "with votes not hidden" do
            let(:votes_hidden) { false }

            it "shows most_voted option to sort" do
              expect(view.available_orders).to include("most_voted")
            end
          end
        end

        context "with votes disabled" do
          let(:votes_enabled) { false }

          it "doesn't show most_voted option to sort" do
            expect(view.available_orders).not_to include("most_voted")
          end
        end

        context "with endorsements enabled" do
          let(:endorsements_enabled) { true }

          it "shows most_endorsed option to sort" do
            expect(view.available_orders).to include("most_endorsed")
          end
        end

        context "with endorsements disabled" do
          let(:endorsements_enabled) { false }

          it "doesn't show most_endorsed option to sort" do
            expect(view.available_orders).not_to include("most_endorsed")
          end
        end

        context "with comments enabled" do
          let(:comments_enabled) { true }

          it "shows most_commented option to sort" do
            expect(view.available_orders).to include("most_commented")
          end
        end

        context "with comments disabled" do
          let(:comments_enabled) { false }

          it "doesn't show most_commented option to sort" do
            expect(view.available_orders).not_to include("most_commented")
          end
        end
      end
    end
  end
end
