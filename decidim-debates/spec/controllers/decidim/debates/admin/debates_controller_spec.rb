# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/softdeleteable_components_examples"

module Decidim
  module Debates
    module Admin
      describe DebatesController do
        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization:) }
        let(:participatory_space) { create(:participatory_process, organization:) }
        let!(:component) { create(:debates_component, participatory_space:) }
        let(:debate) { create(:debate, component:) }
        let(:params) { { id: debate.id } }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_component"] = component
          sign_in current_user
        end

        it_behaves_like "a soft-deletable resource",
                        resource_name: :debate,
                        resource_path: :debates_path,
                        trash_path: :manage_trash_debates_path
      end
    end
  end
end
