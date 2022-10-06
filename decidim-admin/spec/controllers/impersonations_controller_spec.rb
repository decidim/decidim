# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ImpersonationsController, type: :controller do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) do
        create(
          :organization,
          available_authorizations: ["dummy_authorization_handler"]
        )
      end
      let(:current_user) { create(:user, :admin, :confirmed, organization:) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in current_user, scope: :user
      end

      context "when creating a new impersonation" do
        shared_examples "successful authorization" do
          it "successfully creates a new impersonation log entry and redirects to home" do
            post :create, params: params

            authorization = Decidim::Authorization.last
            expect(Decidim::ImpersonationLog.where(
              admin: current_user,
              user: authorization.user
            ).count).to be(1)
            expect(flash[:notice]).to be_present
            expect(subject).to redirect_to("/")
          end
        end

        let(:authorization_params) do
          {
            handler_name: "dummy_authorization_handler",
            document_number: "1234X",
            postal_code: "12345",
            birthday: "01/01/1980"
          }
        end

        let(:managed_user_name) { "Patrick Participant" }

        let(:params) do
          {
            impersonatable_user_id: "new_managed_user",
            impersonate_user: {
              name: managed_user_name,
              authorization: authorization_params
            }
          }
        end

        context "with valid authorization parameters" do
          it_behaves_like "successful authorization"

          it "creates a new managed user with the correct authorization" do
            post :create, params: params

            authorization = Decidim::Authorization.last
            expect(authorization.metadata).to include(
              "document_number" => authorization_params[:document_number],
              "postal_code" => authorization_params[:postal_code]
            )
            expect(authorization.user.name).to eq("Patrick Participant")
          end
        end

        context "with existing user with the same name" do
          before do
            create(
              :user,
              organization:,
              name: managed_user_name
            )
          end

          it_behaves_like "successful authorization"

          it "creates a new managed user" do
            post :create, params: params

            expect(Decidim::User.where(name: managed_user_name).count).to eq(2)
            expect(
              Decidim::User.where(
                name: managed_user_name,
                managed: true
              ).count
            ).to eq(1)
          end
        end

        context "with existing managed user with the same name" do
          before do
            create(
              :user,
              :managed,
              organization:,
              name: managed_user_name
            )
          end

          it_behaves_like "successful authorization"

          it "creates a new managed user" do
            post :create, params: params

            expect(
              Decidim::User.where(
                name: managed_user_name,
                managed: true
              ).count
            ).to eq(2)
          end
        end

        context "with existing managed user with the same identity" do
          before do
            user = create(
              :user,
              :managed,
              organization:,
              name: managed_user_name
            )
            Decidim::Authorization.create!(
              user:,
              name: authorization_params[:handler_name],
              unique_id: authorization_params[:document_number],
              metadata: {
                document_number: "9999X",
                postal_code: "99999"
              }
            )
          end

          it_behaves_like "successful authorization"

          it "takes control of the previously identified managed user and updates the metadata" do
            post :create, params: params

            expect(
              Decidim::User.where(
                name: managed_user_name,
                managed: true
              ).count
            ).to eq(1)

            authorization = Decidim::Authorization.last
            expect(authorization.metadata).to include(
              "document_number" => authorization_params[:document_number],
              "postal_code" => authorization_params[:postal_code]
            )
          end
        end

        context "with existing non-managed user with the same identity" do
          before do
            user = create(
              :user,
              organization:,
              name: managed_user_name
            )
            Decidim::Authorization.create!(
              user:,
              name: authorization_params[:handler_name],
              unique_id: authorization_params[:document_number],
              metadata: {
                document_number: authorization_params[:document_number],
                postal_code: "99999"
              }
            )
          end

          it "fails the authorization" do
            post :create, params: params

            expect(
              Decidim::User.where(
                name: managed_user_name,
                managed: true
              ).count
            ).to eq(0)

            expect(flash[:alert]).to be_present
            expect(subject).to render_template(:new)
          end
        end
      end
    end
  end
end
