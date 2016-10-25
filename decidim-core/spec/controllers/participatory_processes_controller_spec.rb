# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe ParticipatoryProcessesController, type: :controller do
    routes { Decidim::Core::Engine.routes }
    let(:organization) { create(:organization) }
    let!(:unpublished_process) do
      create(
        :participatory_process,
        :unpublished,
        organization: organization
      )
    end

    before do
      @request.env["decidim.current_organization"] = organization
    end

    describe "GET show" do
      context "when the process is unpublished" do
        it "raises an error" do
          expect do
            get :show, params: { id: unpublished_process.id }
          end.to raise_error(ActionController::RoutingError, "Not Found")
        end
      end
    end
  end
end
