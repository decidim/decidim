# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe OpenDataController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let!(:organization) { create(:organization) }
    let(:uploader) { organization.open_data_file }

    before do
      request.env["decidim.current_organization"] = organization
      FileUtils.rm(organization.open_data_file.file.path) if organization.open_data_file.file.exists?
    end

    describe "GET download" do
      before do
        OpenDataJob.perform_now(organization) if generate_file
        get :download
      end

      context "when the open data file exists" do
        let(:generate_file) { true }

        it "redirects to download it" do
          expect(controller).to redirect_to(uploader.url)
        end
      end

      context "when the open data file does not exist" do
        let(:generate_file) { false }

        it "redirects to the homepage" do
          expect(controller).to redirect_to(root_path)
        end

        it "warns the user" do
          expect(controller.flash.alert).to have_content("not yet available")
        end

        it "schedules a generation" do
          expect(Decidim::OpenDataJob).to have_been_enqueued.on_queue("default")
        end
      end
    end
  end
end
