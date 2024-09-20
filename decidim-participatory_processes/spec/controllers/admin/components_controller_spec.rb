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
      end
    end
  end
end
