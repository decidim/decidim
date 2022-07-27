# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    class OrderableFakeController < Decidim::ApplicationController
      include Orderable
    end

    describe OrderableFakeController, type: :controller do
      let(:participatory_process) { create(:participatory_process, :with_steps) }
      let(:active_step_id) { participatory_process.active_step.id }
      let(:component) { create(:component, :with_one_step, participatory_space: participatory_process, manifest_name: "proposals") }
      let(:component_settings) do
        double(
          default_sort_order: component_default_sort_order,
          comments_enabled?: comments_enabled
        )
      end
      let(:current_settings) do
        double(:current_settings,
               default_sort_order: step_default_sort_order,
               votes_enabled?: votes_enabled,
               votes_blocked?: votes_blocked,
               votes_hidden?: votes_hidden,
               endorsements_enabled?: endorsements_enabled,
               comments_enabled?: comments_enabled)
      end
      let(:component_default_sort_order) { "default" }
      let(:step_default_sort_order) { "" }
      let(:votes_enabled) { nil }
      let(:votes_blocked) { nil }
      let(:votes_hidden) { nil }
      let(:endorsements_enabled) { nil }
      let(:comments_enabled) { nil }
      let(:view) { controller.view_context }

      before do
        allow(controller).to receive(:component_settings).and_return(component_settings)
        allow(controller).to receive(:current_settings).and_return(current_settings)
        allow(controller).to receive(:current_participatory_space).and_return(participatory_process)
        allow(controller).to receive(:current_component).and_return(component)
      end

      describe "#default_order" do
        let(:all_sort_orders) { %w(random recent most_endorsed most_voted most_commented most_followed with_more_authors) }
        let(:comments_enabled) { true }

        context "with default settings" do
          it "default_order is random" do
            expect(controller.send(:default_order)).to eq("random")
          end
        end

        context "when step has default_sort_order" do
          let(:component_default_sort_order) { "random" }
          let(:step_default_sort_order) { "with_more_authors" }

          it "use it instead of component's" do
            expect(controller.send(:default_order)).to eq("with_more_authors")
          end
        end

        context "when step has default default_sort_order" do
          let(:component_default_sort_order) { "most_followed" }
          let(:step_default_sort_order) { "default" }
          let(:votes_blocked) { false }

          it "use it instead of component's" do
            expect(controller.send(:default_order)).to eq("random")
          end
        end

        context "when votes are enabled but blocked" do
          let(:votes_enabled) { true }
          let(:votes_blocked) { true }
          let(:votes_hidden) { false }

          it "default_order is most voted" do
            expect(controller.send(:default_order)).to eq("most_voted")
          end
        end

        context "when component has default_sort_order setting" do
          let(:component_settings) do
            double(
              comments_enabled?: comments_enabled,
              default_sort_order:
            )
          end

          describe "by default" do
            let(:default_sort_order) { "default" }

            it "default_order is random" do
              expect(controller.send(:default_order)).to eq("random")
            end
          end

          describe "recent" do
            let(:default_sort_order) { "recent" }

            it "default_order is random" do
              expect(controller.send(:default_order)).to eq(default_sort_order)
            end
          end

          describe "most_endorsed" do
            let(:default_sort_order) { "most_endorsed" }
            let(:endorsements_enabled) { true }

            it "default_order is random" do
              expect(controller.send(:default_order)).to eq(default_sort_order)
            end
          end

          describe "most_commented" do
            let(:default_sort_order) { "most_commented" }
            let(:comments_enabled) { true }

            it "default_order is random" do
              expect(controller.send(:default_order)).to eq(default_sort_order)
            end
          end

          describe "most_followed" do
            let(:default_sort_order) { "most_followed" }

            it "default_order is random" do
              expect(controller.send(:default_order)).to eq(default_sort_order)
            end
          end

          describe "with_more_authors" do
            let(:default_sort_order) { "with_more_authors" }

            it "default_order is random" do
              expect(controller.send(:default_order)).to eq(default_sort_order)
            end
          end
        end
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
