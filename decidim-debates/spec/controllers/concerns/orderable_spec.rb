# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    class OrderableFakeController < Decidim::ApplicationController
      include Orderable
    end

    describe OrderableFakeController do
      let(:participatory_process) { create(:participatory_process, :with_steps) }
      let(:active_step_id) { participatory_process.active_step.id }
      let(:component) { create(:component, :with_one_step, participatory_space: participatory_process, manifest_name: "debates") }
      let(:component_settings) do
        double(
          comments_enabled?: comments_enabled
        )
      end
      let(:current_settings) do
        double(:current_settings,
               comments_enabled?: comments_enabled)
      end
      let(:comments_enabled) { nil }
      let(:view) { controller.view_context }

      before do
        allow(controller).to receive(:component_settings).and_return(component_settings)
        allow(controller).to receive(:current_settings).and_return(current_settings)
        allow(controller).to receive(:current_participatory_space).and_return(participatory_process)
        allow(controller).to receive(:current_component).and_return(component)
      end

      describe "#available_orders" do
        context "with comments disabled" do
          let(:comments_enabled) { false }

          it "does not show most_commented option to sort" do
            expect(view.available_orders).not_to include("most_commented")
          end
        end

        context "with comments enabled" do
          let(:comments_enabled) { true }
          let!(:debate_with_comments) { create(:debate, component:, comments_count: 5) }

          it "shows most_commented option to sort" do
            expect(view.available_orders).to include("most_commented")
          end
        end

        context "with or without comments and most_commented availability" do
          let!(:debate_without_comments) { create(:debate, component:) }
          let!(:debate_with_comments) { create(:debate, component:, comments_count: 5) }
          let(:comments_enabled) { true }

          context "when there are no debates with comments" do
            before do
              debate_with_comments.update!(comments_count: 0)
            end

            it "does not show most_commented option to sort" do
              expect(view.available_orders).not_to include("most_commented")
            end
          end

          context "when there are debates with comments" do
            it "shows most_commented option to sort" do
              expect(view.available_orders).to include("most_commented")
            end
          end
        end
      end

      describe "#most_commented_order_available?" do
        let!(:debate_without_comments) { create(:debate, component:) }
        let!(:debate_with_comments) { create(:debate, component:, comments_count: 5) }

        context "when comments are disabled" do
          let(:component) { create(:debates_component, :with_comments_disabled) }

          it "returns false" do
            expect(controller.send(:most_commented_order_available?)).to be false
          end
        end

        context "when comments are enabled" do
          context "when there are debates with only zero comments" do
            before do
              debate_with_comments.update!(comments_count: 0)
            end

            it "returns false" do
              expect(controller.send(:most_commented_order_available?)).to be false
            end
          end

          context "when there are debates with comments" do
            it "returns true" do
              expect(controller.send(:most_commented_order_available?)).to be true
            end
          end

          context "when debates are hidden" do
            before do
              create(:moderation, reportable: debate_with_comments, hidden_at: Time.current)
            end

            it "returns false" do
              expect(controller.send(:most_commented_order_available?)).to be false
            end
          end
        end
      end
    end
  end
end
