# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    describe ParticipatoryProcessGroupsController do
      routes { Decidim::ParticipatoryProcesses::Engine.routes }

      let(:organization) { create(:organization) }
      let!(:process_group) { create(:participatory_process_group, organization:) }

      describe "GET show" do
        before do
          request.env["decidim.current_organization"] = organization
        end

        context "when the process group belongs to the organization" do
          it "shows the content" do
            get :show, params: { id: process_group.id, locale: I18n.locale }

            expect(response).to be_successful
          end
        end

        context "when the process group do not belong to the organization" do
          let!(:process_group) { create(:participatory_process_group) }

          it "redirects to 404 if there are not any" do
            expect { get :show, params: { id: process_group.id, locale: I18n.locale } }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
