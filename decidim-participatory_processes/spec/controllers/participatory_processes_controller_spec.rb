# frozen_string_literal: true

require "spec_helper"
require "decidim/dev/test/promoted_participatory_processes_shared_examples"

module Decidim
  module ParticipatoryProcesses
    describe ParticipatoryProcessesController, type: :controller do
      routes { Decidim::ParticipatoryProcesses::Engine.routes }

      let(:organization) { create(:organization) }
      let!(:unpublished_process) do
        create(
          :participatory_process,
          :unpublished,
          organization: organization
        )
      end

      describe "published_processes" do
        before do
          request.env["decidim.current_organization"] = organization
        end

        it "includes only published participatory processes" do
          published = create_list(
            :participatory_process,
            2,
            :published,
            organization: organization
          )

          expect(controller.helpers.participatory_processes.count).to eq(2)
          expect(controller.helpers.participatory_processes.to_a).to include(published.first)
          expect(controller.helpers.participatory_processes.to_a).to include(published.last)
          expect(controller.helpers.participatory_processes.to_a).not_to include(unpublished_process)
        end

        it "redirects to 404 if there aren't any" do
          expect { get :index }.to raise_error(ActionController::RoutingError)
        end
      end

      include_examples "with promoted participatory processes"

      describe "collection" do
        before do
          request.env["decidim.current_organization"] = organization
        end

        let(:other_organization) { create(:organization) }

        it "includes a heterogeneous array of processes and groups" do
          published = create_list(
            :participatory_process,
            2,
            :published,
            organization: organization
          )

          _unpublished = create_list(
            :participatory_process,
            2,
            :unpublished,
            organization: organization
          )

          organization_groups = create_list(
            :participatory_process_group,
            2,
            :with_participatory_processes,
            organization: organization
          )

          _other_groups = create_list(
            :participatory_process_group,
            2,
            :with_participatory_processes,
            organization: other_organization
          )

          expect(controller.helpers.collection)
            .to match_array([*published, *organization_groups])
        end

        describe "filter" do
          it "ignores invalid filters" do
            controller.params = { filter: "foo-filter" }

            expect(controller.helpers.filter).to eq("active")
          end

          it "allows known filters" do
            controller.params = { filter: "past" }

            expect(controller.helpers.filter).to eq("past")
          end
        end
      end

      describe "default_date_filter" do
        let!(:active) { create(:participatory_process, :published, :active, organization: organization) }
        let!(:upcoming) { create(:participatory_process, :published, :upcoming, organization: organization) }
        let!(:past) { create(:participatory_process, :published, :past, organization: organization) }

        it "defaults to active if there are active published processes" do
          expect(controller.helpers.default_date_filter).to eq("active")
        end

        it "defaults to upcoming if there are upcoming (but no active) published processes" do
          active.update(published_at: nil)
          expect(controller.helpers.default_date_filter).to eq("upcoming")
        end

        it "defaults to past if there are past (but no active nor upcoming) published processes" do
          active.update(published_at: nil)
          upcoming.update(published_at: nil)
          expect(controller.helpers.default_date_filter).to eq("past")
        end
      end

      describe "GET show" do
        context "when the process is unpublished" do
          it "redirects to root path" do
            get :show, params: { slug: unpublished_process.slug }

            expect(response).to redirect_to("/")
          end
        end
      end
    end
  end
end
