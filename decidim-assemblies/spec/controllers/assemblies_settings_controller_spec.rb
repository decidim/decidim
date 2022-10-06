# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    module Admin
      describe AssembliesSettingsController, type: :controller do
        routes { Decidim::Assemblies::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization:) }
        let!(:assemblies_setting) { create(:assemblies_setting, organization:) }

        before do
          request.env["decidim.current_organization"] = organization
          sign_in current_user
        end

        describe "PATCH update" do
          let(:assemblies_setting_params) do
            {
              enable_organization_chart: assemblies_setting.enable_organization_chart
            }
          end

          it "updates the assemblies settings" do
            patch :update, params: { assemblies_setting: assemblies_setting_params }

            expect(response).to redirect_to edit_assemblies_settings_path
          end
        end
      end
    end
  end
end
