# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    module Admin
      describe AssemblyMembersController, type: :controller do
        routes { Decidim::Assemblies::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization: organization) }
        let!(:assembly) { create(:assembly, organization: organization) }
        let(:params) { { assembly_slug: assembly.slug } }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_component"] = assembly
          sign_in current_user
        end
      end
    end
  end
end
