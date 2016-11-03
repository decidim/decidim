# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Admin
    describe ParticipatoryProcessesController, type: :controller do
      let(:organization) { create(:organization) }
      let!(:external_process) { create :participatory_process }

      before do
        @request.env["decidim.current_organization"] = organization
        @request.env["devise.mapping"] = Devise.mappings[:user]
      end

      describe "GET show" do
        context "process in another organization" do
          let(:user) { create(:user, :admin, :confirmed, organization: organization) }

          before do
            sign_in user, scope: :user
          end

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
