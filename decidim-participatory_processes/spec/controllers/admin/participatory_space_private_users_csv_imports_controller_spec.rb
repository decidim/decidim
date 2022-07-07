# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    module Admin
      describe ParticipatorySpacePrivateUsersCsvImportsController, type: :controller do
        routes { Decidim::ParticipatoryProcesses::AdminEngine.routes }

        let!(:organization) { create :organization }
        let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
        let!(:user) { create(:user, organization: organization) }
        let!(:private_user) { create(:participatory_space_private_user, user: user) }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_process"] = private_user.privatable_to
          sign_in admin, scope: :user
        end

        it "is routed to" do
          delete :destroy_all, params: { participatory_process_slug: private_user.privatable_to.slug }

          expect(response).to be_redirect
        end

        it "suppress the existing users" do
          expect do
            delete :destroy_all, params: { participatory_process_slug: private_user.privatable_to.slug }
          end.to change { Decidim::ParticipatorySpacePrivateUser.by_participatory_space(private_user.privatable_to).count }.by(-1)
        end
      end
    end
  end
end
