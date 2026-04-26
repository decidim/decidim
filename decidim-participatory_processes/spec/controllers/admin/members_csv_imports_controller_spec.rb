# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    module Admin
      describe MembersCsvImportsController do
        routes { Decidim::ParticipatoryProcesses::AdminEngine.routes }

        let!(:organization) { create(:organization) }
        let!(:admin) { create(:user, :admin, :confirmed, organization:) }
        let!(:user) { create(:user, organization:) }
        let!(:participatory_space) { create(:participatory_process, organization: user.organization, has_members: true) }
        let!(:member) { create(:member, user:, participatory_space:) }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_process"] = member.participatory_space
          sign_in admin, scope: :user
        end

        it "is routed to" do
          delete :destroy_all, params: { participatory_process_slug: member.participatory_space.slug }

          expect(response).to be_redirect
        end

        it "suppress the existing users" do
          expect do
            delete :destroy_all, params: { participatory_process_slug: member.participatory_space.slug }
          end.to change { Decidim::ParticipatorySpace::Member.by_participatory_space(member.participatory_space).count }.by(-1)
        end
      end
    end
  end
end
