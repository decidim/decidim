# frozen_string_literal: true

require "spec_helper"
require "decidim/dev/test/promoted_participatory_processes_shared_examples"

module Decidim
  module ParticipatoryProcesses
    describe ParticipatoryProcessesController do
      routes { Decidim::ParticipatoryProcesses::Engine.routes }

      let(:organization) { create(:organization) }
      let!(:unpublished_process) do
        create(
          :participatory_process,
          :unpublished,
          organization:
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
            organization:
          )

          expect(controller.helpers.participatory_processes.count).to eq(2)
          expect(controller.helpers.participatory_processes.to_a).to include(published.first)
          expect(controller.helpers.participatory_processes.to_a).to include(published.last)
          expect(controller.helpers.participatory_processes.to_a).not_to include(unpublished_process)
        end

        it "redirects to 404 if there are not any" do
          expect { get :index, params: { locale: I18n.locale } }.to raise_error(ActionController::RoutingError)
        end
      end

      include_examples "with promoted participatory processes and groups"

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
            organization:
          )

          _unpublished = create_list(
            :participatory_process,
            2,
            :unpublished,
            organization:
          )

          organization_groups = create_list(
            :participatory_process_group,
            2,
            :with_participatory_processes,
            organization:
          )

          _other_groups = create_list(
            :participatory_process_group,
            2,
            :with_participatory_processes,
            organization: other_organization
          )

          _manipulated_other_groups = create(
            :participatory_process_group,
            participatory_processes: [create(:participatory_process, organization:)]
          )

          expect(controller.helpers.collection)
            .to match_array(published + organization_groups)
        end

        it "orders processes by weight" do
          process1 = create(:participatory_process, :published, organization:, weight: 2)
          process2 = create(:participatory_process, :published, organization:, weight: 1)

          expect(controller.helpers.collection).to eq([process2, process1])
        end
      end

      describe "default_date_filter" do
        let!(:active) { create(:participatory_process, :published, :active, organization:) }
        let!(:upcoming) { create(:participatory_process, :published, :upcoming, organization:) }
        let!(:past) { create(:participatory_process, :published, :past, organization:) }

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
          it "redirects to sign in path" do
            get :show, params: { slug: unpublished_process.slug, locale: I18n.locale }

            expect(response).to redirect_to("/users/sign_in")
          end

          context "with signed in user" do
            let!(:user) { create(:user, :confirmed, organization:) }

            before do
              sign_in user, scope: :user
            end

            it "redirects to root path" do
              get :show, params: { slug: unpublished_process.slug, locale: I18n.locale }

              expect(response).to redirect_to("/")
            end
          end
        end
      end
    end
  end
end
