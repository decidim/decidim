# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe InitiativesSettingsController, type: :controller do
        routes { Decidim::Initiatives::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization: organization) }
        let!(:initiatives_settings) { create(:initiatives_settings, organization: organization) }

        before do
          request.env["decidim.current_organization"] = organization
          sign_in current_user
        end

        describe "PATCH update" do
          let(:initiatives_settings_params) do
            {
              initiatives_order: initiatives_settings.initiatives_order
            }
          end

          it "updates the initiatives settings" do
            patch :update, params: { id: initiatives_settings.id, initiatives_settings: initiatives_settings_params }

            expect(response).to redirect_to edit_initiatives_setting_path
          end
        end
      end
    end
  end
end
