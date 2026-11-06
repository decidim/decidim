# frozen_string_literal: true

require "spec_helper"
require "decidim/meetings/test/factories"

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

      describe "GET show" do
        let!(:components) { create_list(:component, 2, :published, manifest_name: "meetings", organization:) }
        let!(:meetings) { components.map { |component| create(:meeting, :published, component:) } }
        let!(:action_logs) do
          meetings.map do |meeting|
            create(
              :action_log,
              action: "update",
              visibility: "admin-only",
              resource: meeting,
              organization:,
              participatory_space: meeting.component.participatory_space,
              component: meeting.component
            )
          end
        end

        it "renders the show template" do
          get :show

          expect(response).to render_template("show")
        end

        it "eager loads the component and its space for the log resources" do
          logs = controller.send(:latest_action_logs)

          expect(logs).to match_array(action_logs)

          logs.each do |log|
            expect(log.association(:resource).loaded?).to be(true)
            expect(log.resource.association(:component).loaded?).to be(true)
            expect(log.resource.component.association(:participatory_space).loaded?).to be(true)
            expect(log.resource.component.participatory_space.association(:organization).loaded?).to be(true)
          end
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
