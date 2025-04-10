# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe EditorImagesController do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:editor_images_path) { Rails.application.routes.url_helpers.editor_images_url(organization.open_data_file.blob, only_path: true) }
    let(:user) { create(:user, :confirmed, organization:) }
    let(:admin) { create(:user, :confirmed, :admin, organization:) }
    let(:image) { upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")) }
    let(:invalid_image) { upload_test_file(Decidim::Dev.test_file("invalid.jpeg", "image/jpeg")) }
    let(:valid_params) { { image: } }
    let(:invalid_params) { { image: invalid_image } }

    before do
      request.env["decidim.current_organization"] = organization
    end

    describe "POST create" do
      context "when no user is signed in" do
        it "does not create an editor image" do
          expect do
            post :create, params: valid_params
          end.not_to(change(Decidim::EditorImage, :count))

          expect(response).to have_http_status(:redirect)
        end
      end

      context "when user has no admin permissions" do
        before do
          sign_in user
        end

        it "does not create an editor image" do
          expect do
            post :create, params: valid_params
          end.not_to(change(Decidim::EditorImage, :count))

          expect(response).to have_http_status(:redirect)
        end
      end

      shared_examples "handles editor image" do
        it "creates an editor image" do
          expect do
            post :create, params: valid_params
          end.to change(Decidim::EditorImage, :count).by(1)

          expect(response).to have_http_status(:ok)
        end

        context "when file is not valid" do
          it "does not create an editor image and returns an error message" do
            expect do
              post :create, params: invalid_params
            end.not_to(change(Decidim::EditorImage, :count))

            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.body).to include("Error uploading image")
          end
        end
      end

      context "when admin is signed in" do
        before do
          sign_in admin
        end

        it_behaves_like "handles editor image"
      end

      context "when user is a process admin" do
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:user) { create(:process_admin, :confirmed, organization:, participatory_process:) }

        before do
          sign_in user
        end

        it_behaves_like "handles editor image"
      end
    end
  end
end
