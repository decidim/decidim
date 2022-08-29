# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    module Admin
      describe ComponentsController, type: :controller do
        routes { Decidim::Conferences::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization:) }
        let!(:conference) do
          create(
            :conference,
            :published,
            organization:
          )
        end
        let(:component) do
          create(
            :component,
            manifest_name: :dummy,
            participatory_space: conference
          )
        end

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_conference"] = conference
          sign_in current_user
        end

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

          it "publishes the default step settings change" do
            expect(Decidim::SettingsChange).to receive(:publish).with(
              component,
              hash_including("comments_blocked" => false),
              hash_including("comments_blocked" => true)
            )

            patch :update, params: { conference_slug: conference.slug, id: component.id, component: component_params }

            expect(response).to redirect_to components_path
          end
        end
      end
    end
  end
end
