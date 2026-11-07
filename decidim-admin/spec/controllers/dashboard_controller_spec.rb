# frozen_string_literal: true

require "spec_helper"
require "decidim/meetings/test/factories"
require "decidim/proposals/test/factories"

module Decidim
  module Admin
    describe DashboardController do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create(:organization) }
      let(:current_user) { create(:user, :admin, :confirmed, organization:) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in current_user, scope: :user
      end

      def sql_queries
        queries = []
        callback = lambda do |_name, _start, _finish, _id, payload|
          sql = payload[:sql]
          queries << sql if sql&.match?(/^SELECT .* FROM "[^"]+"/)
        end

        ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
          yield
        end

        queries
      end

      describe "GET show" do
        let!(:components) do
          [
            create(:component, :published, manifest_name: "meetings", organization:),
            create(:component, :published, manifest_name: "meetings", organization:),
            create(:component, :published, manifest_name: "proposals", organization:),
            create(:component, :published, manifest_name: "proposals", organization:)
          ]
        end
        let!(:meetings) { components.first(2).map { |component| create(:meeting, :published, component:) } }
        let!(:proposals) { components.last(2).map { |component| create(:proposal, component:) } }
        let!(:action_logs) do
          (meetings + proposals).map do |resource|
            create(
              :action_log,
              action: "update",
              visibility: "admin-only",
              resource:,
              organization:,
              participatory_space: resource.component.participatory_space,
              component: resource.component
            )
          end
        end

        it "renders the show template" do
          get :show

          expect(response).to render_template("show")
        end

        it "eager loads the component and its space for the log resources of each resource type" do
          logs = controller.send(:latest_action_logs)

          expect(logs).to match_array(action_logs)
          expect(logs.map(&:resource_type).uniq).to contain_exactly(
            "Decidim::Meetings::Meeting",
            "Decidim::Proposals::Proposal"
          )

          logs.each do |log|
            expect(log.association(:resource).loaded?).to be(true)
            expect(log.resource.association(:component).loaded?).to be(true)
            expect(log.resource.component.association(:participatory_space).loaded?).to be(true)
            expect(log.resource.component.participatory_space.association(:organization).loaded?).to be(true)
          end
        end

        it "loads the associations with one query per resource type instead of one per log" do
          queries = sql_queries do
            controller.send(:latest_action_logs)
          end

          tables = queries.filter_map { |sql| sql[/FROM "([^"]+)"/, 1] }.tally

          # Two resource types with two logs each: the resources' component,
          # participatory space and organization are loaded once per resource type,
          # plus the single query that preloads the component and the participatory
          # space of the logs themselves. Preloading each log individually would run
          # one query per log (4) for each of these tables instead of the 2 per type.
          expect(tables["decidim_components"]).to eq(3)
          expect(tables["decidim_participatory_processes"]).to eq(3)
          expect(tables["decidim_organizations"]).to eq(2)
        end

        context "when the resource does not have a component association" do
          let(:component) { create(:component, :published, manifest_name: "blogs", organization:) }

          it "does not try to preload it" do
            create(
              :action_log,
              action: "create",
              visibility: "admin-only",
              resource: component,
              organization:,
              participatory_space: component.participatory_space,
              component:
            )

            expect { controller.send(:latest_action_logs) }.not_to raise_error
          end
        end
      end
    end
  end
end
