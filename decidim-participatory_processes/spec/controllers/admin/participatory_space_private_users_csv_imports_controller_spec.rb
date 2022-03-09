# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    module Admin
      describe ParticipatorySpacePrivateUsersCsvImportsController, type: :controller do
        routes { Decidim::ParticipatoryProcesses::AdminEngine.routes }

        let(:organization) { create :organization }
        let(:admin) { create(:user, :admin, :confirmed, organization: organization) }
        let(:user) { create(:user, organization: organization) }
        let(:private_user) { create(:participatory_space_private_user, user: user) }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_process"] = private_user.privatable_to
          sign_in admin, scope: :user
        end

        it 'is routed to' do
          expect(:delete => "destroy_all").to route_to(:controller => 'decidim/participatory_processes/admin/participatory_space_private_users_csv_imports', :action => 'destroy_all')
        end

        it "suppress the existing users" do

          get :destroy_all

          expect (response).to change { Decidim::ParticipatorySpacePrivateUser.by_participatory_space(private_user.privatable_to).count }.by(1)
        end
      end
    end
  end
end
