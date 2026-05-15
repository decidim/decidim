# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    class OrderableFakeController < Decidim::ApplicationController
      include Orderable
    end

    describe OrderableFakeController do
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
               comments_enabled?: comments_enabled)
      end
      let(:component_default_sort_order) { "automatic" }
      let(:step_default_sort_order) { "" }
      let(:votes_enabled) { nil }
      let(:votes_blocked) { nil }
      let(:votes_hidden) { nil }
      let(:likes_enabled) { nil }
      let(:comments_enabled) { nil }
      let(:view) { controller.view_context }

      before do
        allow(controller).to receive(:component_settings).and_return(component_settings)
        allow(controller).to receive(:current_settings).and_return(current_settings)
        allow(controller).to receive(:current_participatory_space).and_return(participatory_process)
        allow(controller).to receive(:current_component).and_return(component)
      end

      describe "#default_order" do
        let(:all_sort_orders) { %w(random recent most_liked most_voted most_commented most_followed with_more_authors) }
        let(:comments_enabled) { true }

        context "with default settings" do
          it "default_order is random" do
            expect(controller.send(:default_order)).to eq("random")
          end
        end

        context "when step has default_sort_order" do
          let(:component_default_sort_order) { "random" }
          let(:step_default_sort_order) { "most_commented" }
          let!(:proposal_with_comments) { create(:proposal, component:, comments_count: 5) }

          it "use it instead of component's" do
            expect(controller.send(:default_order)).to eq("most_commented")
          end
        end

        context "when step has default default_sort_order" do
          let(:component_default_sort_order) { "most_followed" }
          let(:step_default_sort_order) { "automatic" }
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
            let(:default_sort_order) { "automatic" }

            it "default_order is random" do
              expect(controller.send(:default_order)).to eq("random")
            end
          end

          describe "recent" do
            let(:default_sort_order) { "recent" }

            it "default_order is recent" do
              expect(controller.send(:default_order)).to eq(default_sort_order)
            end
          end

          describe "most_liked" do
            let(:default_sort_order) { "most_liked" }
            let(:likes_enabled) { true }

            context "when there are no proposals with likes" do
              it "defaults to random" do
                expect(controller.send(:default_order)).to eq("random")
              end
            end

            context "when there are proposals with likes" do
              let!(:proposal_with_likes) { create(:proposal, component:, likes_count: 5) }

              it "default_order is most_liked" do
                expect(controller.send(:default_order)).to eq(default_sort_order)
              end
            end
          end

          describe "most_commented" do
            let(:default_sort_order) { "most_commented" }
            let(:comments_enabled) { true }

            context "when there are no proposals with comments" do
              it "defaults to random" do
                expect(controller.send(:default_order)).to eq("random")
              end
            end

            context "when there are proposals with comments" do
              let!(:proposal_with_comments) { create(:proposal, component:, comments_count: 5) }

              it "default_order is most_commented" do
                expect(controller.send(:default_order)).to eq(default_sort_order)
              end
            end
          end

          describe "most_followed" do
            let(:default_sort_order) { "most_followed" }

            it "default_order is most_followed" do
              expect(controller.send(:default_order)).to eq(default_sort_order)
            end
          end

          describe "with_more_authors" do
            let(:default_sort_order) { "with_more_authors" }

            context "when there are no proposals with coauthors" do
              it "defaults to random" do
                expect(controller.send(:default_order)).to eq("random")
              end
            end

            context "when there are proposals with coauthors" do
              let!(:proposal_with_coauthors) { create(:proposal, component:) }
              let!(:coauthorships) { create_list(:coauthorship, 2, coauthorable: proposal_with_coauthors) }

              it "default_order is with_more_authors" do
                expect(controller.send(:default_order)).to eq(default_sort_order)
              end
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

          it "does not show most_voted option to sort" do
            expect(view.available_orders).not_to include("most_voted")
          end
        end

        context "with likes enabled" do
          let(:likes_enabled) { true }
          let!(:proposal_with_likes) { create(:proposal, component:, likes_count: 5) }

          it "shows most_liked option to sort" do
            expect(view.available_orders).to include("most_liked")
          end
        end

        context "with likes disabled" do
          let(:likes_enabled) { false }

          it "does not show most_liked option to sort" do
            expect(view.available_orders).not_to include("most_liked")
          end
        end

        context "with or without likes and most_liked availability" do
          let!(:proposal_without_likes) { create(:proposal, component:) }
          let!(:proposal_with_likes) { create(:proposal, component:, likes_count: 5) }
          let(:likes_enabled) { true }

          context "when there are no proposals with likes" do
            before do
              proposal_with_likes.update!(likes_count: 0)
            end

            it "does not show most_liked option to sort" do
              expect(view.available_orders).not_to include("most_liked")
            end
          end

          context "when there are proposals with likes" do
            it "shows most_liked option to sort" do
              expect(view.available_orders).to include("most_liked")
            end
          end
        end

        context "with comments enabled" do
          let(:comments_enabled) { true }
          let!(:proposal_with_comments) { create(:proposal, component:, comments_count: 5) }

          it "shows most_commented option to sort" do
            expect(view.available_orders).to include("most_commented")
          end
        end

        context "with comments disabled" do
          let(:comments_enabled) { false }

          it "does not show most_commented option to sort" do
            expect(view.available_orders).not_to include("most_commented")
          end
        end

        context "with or without comments and most_commented availability" do
          let!(:proposal_without_comments) { create(:proposal, component:) }
          let!(:proposal_with_comments) { create(:proposal, component:, comments_count: 5) }
          let(:comments_enabled) { true }

          context "when there are no proposals with comments" do
            before do
              proposal_with_comments.update!(comments_count: 0)
            end

            it "does not show most_commented option to sort" do
              expect(view.available_orders).not_to include("most_commented")
            end
          end

          context "when there are proposals with comments" do
            it "shows most_commented option to sort" do
              expect(view.available_orders).to include("most_commented")
            end
          end
        end

        context "with or without coauthors and with_more_authors availability" do
          let!(:proposal_with_single_author) { create(:proposal, component:) }
          let!(:proposal_with_coauthors) { create(:proposal, component:) }
          let!(:coauthorships) { create_list(:coauthorship, 2, coauthorable: proposal_with_coauthors) }

          context "when there are no proposals with coauthors" do
            before do
              proposal_with_coauthors.destroy
            end

            it "does not show with_more_authors option to sort" do
              expect(view.available_orders).not_to include("with_more_authors")
            end
          end

          context "when there are proposals with coauthors" do
            it "shows with_more_authors option to sort" do
              expect(view.available_orders).to include("with_more_authors")
            end
          end
        end
      end

      describe "#with_more_authors_order_available?" do
        let!(:proposal_with_single_author) { create(:proposal, component:) }
        let!(:proposal_with_coauthors) { create(:proposal, component:) }
        let!(:coauthorships) { create_list(:coauthorship, 2, coauthorable: proposal_with_coauthors) }

        context "when there are proposals with only single author" do
          before do
            coauthorships.each(&:destroy)
          end

          it "returns false" do
            expect(controller.send(:with_more_authors_order_available?)).to be false
          end
        end

        context "when there are proposals with coauthors" do
          it "returns true" do
            expect(controller.send(:with_more_authors_order_available?)).to be true
          end
        end

        context "when proposals are not published" do
          before do
            proposal_with_coauthors.update!(published_at: nil)
          end

          it "returns false" do
            expect(controller.send(:with_more_authors_order_available?)).to be false
          end
        end

        context "when proposals are hidden" do
          before do
            create(:moderation, reportable: proposal_with_coauthors, hidden_at: Time.current)
          end

          it "returns false" do
            expect(controller.send(:with_more_authors_order_available?)).to be false
          end
        end
      end

      describe "#most_commented_order_available?" do
        let!(:proposal_without_comments) { create(:proposal, component:) }
        let!(:proposal_with_comments) { create(:proposal, component:, comments_count: 5) }

        context "when comments are disabled" do
          let(:component) { create(:proposal_component, :with_comments_disabled) }

          it "returns false" do
            expect(controller.send(:most_commented_order_available?)).to be false
          end
        end

        context "when comments are enabled" do
          context "when there are proposals with only zero comments" do
            before do
              proposal_with_comments.update!(comments_count: 0)
            end

            it "returns false" do
              expect(controller.send(:most_commented_order_available?)).to be false
            end
          end

          context "when there are proposals with comments" do
            it "returns true" do
              expect(controller.send(:most_commented_order_available?)).to be true
            end
          end

          context "when proposals are not published" do
            before do
              proposal_with_comments.update!(published_at: nil)
            end

            it "returns false" do
              expect(controller.send(:most_commented_order_available?)).to be false
            end
          end

          context "when proposals are hidden" do
            before do
              create(:moderation, reportable: proposal_with_comments, hidden_at: Time.current)
            end

            it "returns false" do
              expect(controller.send(:most_commented_order_available?)).to be false
            end
          end
        end
      end

      describe "#most_liked_order_available?" do
        let!(:proposal_without_likes) { create(:proposal, component:) }
        let!(:proposal_with_likes) { create(:proposal, component:, likes_count: 5) }

        context "when there are proposals with only zero likes" do
          before do
            proposal_with_likes.update!(likes_count: 0)
          end

          it "returns false" do
            expect(controller.send(:most_liked_order_available?)).to be false
          end
        end

        context "when there are proposals with likes" do
          it "returns true" do
            expect(controller.send(:most_liked_order_available?)).to be true
          end
        end

        context "when proposals are not published" do
          before do
            proposal_with_likes.update!(published_at: nil)
          end

          it "returns false" do
            expect(controller.send(:most_liked_order_available?)).to be false
          end
        end

        context "when proposals are hidden" do
          before do
            create(:moderation, reportable: proposal_with_likes, hidden_at: Time.current)
          end

          it "returns false" do
            expect(controller.send(:most_liked_order_available?)).to be false
          end
        end
      end
    end
  end
end
