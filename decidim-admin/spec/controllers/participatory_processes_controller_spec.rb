# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ParticipatoryProcessesController, type: :controller do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }

      before do
        @request.env["decidim.current_organization"] = organization
        sign_in user, scope: :user
      end

      describe "GET show" do
        context "process in another organization" do
          let!(:external_process) { create :participatory_process }

          it "is not visible to the user" do
            expect do
              get :show, params: { id: external_process.id }
            end.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
