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
        let!(:privatable_to) { create(:participatory_process, organization: user.organization, private_space: true) }
        let!(:member) { create(:member, user:, privatable_to:) }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_participatory_process"] = member.privatable_to
          sign_in admin, scope: :user
        end

        it "is routed to" do
          delete :destroy_all, params: { participatory_process_slug: member.privatable_to.slug }

          expect(response).to be_redirect
        end

        it "suppress the existing users" do
          expect do
            delete :destroy_all, params: { participatory_process_slug: member.privatable_to.slug, locale: I18n.locale }
          end.to change { Decidim::ParticipatorySpace::Member.by_participatory_space(member.privatable_to).count }.by(-1)
        end
      end
    end
  end
end
