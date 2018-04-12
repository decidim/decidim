# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    module Admin
      describe FeaturesController, type: :controller do
        routes { Decidim::Assemblies::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization: organization) }
        let!(:assembly) do
          create(
            :assembly,
            :published,
            organization: organization
          )
        end
        let(:feature) do
          create(
            :feature,
            manifest_name: :dummy,
            participatory_space: assembly
          )
        end

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_assembly"] = assembly
          sign_in current_user
        end

        describe "PATCH update" do
          let(:feature_params) do
            {
              name_en: "Dummy feature",
              settings: {
                comments_enabled: true
              },
              default_step_settings: {
                comments_blocked: true
              }
            }
          end

          it "publishes the default step settings change" do
            expect(Decidim::SettingsChange).to receive(:publish).with(
              feature,
              {},
              hash_including("comments_blocked" => true)
            )

            patch :update, params: { assembly_slug: assembly.slug, id: feature.id, feature: feature_params }

            expect(response).to redirect_to features_path
          end
        end
      end
    end
  end
end
