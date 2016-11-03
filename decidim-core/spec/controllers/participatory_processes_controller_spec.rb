# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe ParticipatoryProcessesController, type: :controller do
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
        it "redirects to root path" do
          get :show, params: { id: unpublished_process.id }

          expect(response).to redirect_to("/")
        end
      end
    end
  end
end
