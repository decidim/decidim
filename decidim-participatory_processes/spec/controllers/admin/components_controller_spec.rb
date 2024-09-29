# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    module Admin
      describe ComponentsController do
        routes { Decidim::ParticipatoryProcesses::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization:) }
        let!(:participatory_process) do
          create(
            :participatory_process,
            :published,
            organization:
          )
        end
        let(:component) do
          create(
            :component,
            manifest_name: :dummy,
            participatory_space: participatory_process
          )
        end

        let(:space) { participatory_process }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_process"] = participatory_process
          sign_in current_user
        end

        it_behaves_like "a reorder components controller", slug_attribute: :participatory_process_slug
        it_behaves_like "a components controller to hide", slug_attribute: :participatory_process_slug

        describe "PATCH update" do
          let(:component_params) do
            {
              name_en: "Dummy component",
              settings: {
                comments_enabled: true,
                dummy_global_translatable_text_en: "Dummy text"
              },
              default_step_settings: {
                comments_blocked: true,
                dummy_step_translatable_text_en: "Dummy text"
              }
            }
          end

          it "does not publish the default step settings change" do
            expect(Decidim::SettingsChange).not_to receive(:publish)

            patch :update, params: { participatory_process_slug: participatory_process.slug, id: component.id, component: component_params }

            expect(response).to redirect_to components_path
          end
        end

        describe "PATCH soft_delete" do
          it "soft deletes the component" do
            expect(Decidim::Commands::SoftDeleteResource).to receive(:call).with(component, current_user).and_call_original

            patch :soft_delete, params: { participatory_process_slug: participatory_process.slug, id: component.id }

            expect(response).to redirect_to components_path
            expect(flash[:notice]).to be_present
            expect(component.reload.deleted_at).not_to be_nil
          end
        end

        describe "PATCH restore" do
          before do
            component.update!(deleted_at: Time.current)
          end

          it "restores the component" do
            expect(Decidim::Commands::RestoreResource).to receive(:call).with(component, current_user).and_call_original

            patch :restore, params: { participatory_process_slug: participatory_process.slug, id: component.id }

            expect(response).to redirect_to components_path
            expect(flash[:notice]).to be_present
            expect(component.reload.deleted_at).to be_nil
          end
        end

        describe "GET manage_trash" do
          let!(:deleted_component) { create(:component, :trashed, participatory_space: participatory_process) }
          let!(:active_component) { create(:component, participatory_space: participatory_process) }

          it "lists only deleted components" do
            get :manage_trash, params: { participatory_process_slug: participatory_process.slug }

            expect(response).to have_http_status(:ok)
            expect(controller.send(:deleted_components)).not_to include(active_component)
            expect(controller.send(:deleted_components)).to contain_exactly(deleted_component)
          end

          it "renders the deleted components template" do
            get :manage_trash, params: { participatory_process_slug: participatory_process.slug }

            expect(response).to render_template(:manage_trash)
          end
        end
      end
    end
  end
end
