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

      describe "participatory_processes" do
        before do
          request.env["decidim.current_organization"] = organization
        end

        it "orders them by end_date" do
          unpublished = create(
            :participatory_process,
            :with_steps,
            :unpublished,
            organization: organization
          )

          last = create(
            :participatory_process,
            :with_steps,
            :published,
            organization: organization,
            end_date: nil
          )
          last.active_step.update!(end_date: nil)

          first = create(
            :participatory_process,
            :with_steps,
            :published,
            organization: organization,
            end_date: Date.current.advance(days: 10)
          )
          first.active_step.update!(end_date: Date.current.advance(days: 2))

          second = create(
            :participatory_process,
            :with_steps,
            :published,
            organization: organization,
            end_date: Date.current.advance(days: 20)
          )
          second.active_step.update!(end_date: Date.current.advance(days: 4))

          expect(controller.helpers.participatory_processes.count).to eq(3)
          expect(controller.helpers.participatory_processes).not_to include(unpublished)
          expect(controller.helpers.participatory_processes.first).to eq(first)
          expect(controller.helpers.participatory_processes.to_a[1]).to eq(second)
          expect(controller.helpers.participatory_processes.to_a.last).to eq(last)
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
            .to match_array([*published, *organization_groups, *organization_groups.map(&:participatory_processes).flatten])
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
