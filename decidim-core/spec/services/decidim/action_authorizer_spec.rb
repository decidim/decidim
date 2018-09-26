# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ActionAuthorizer do
    subject { authorizer }

    let(:organization) { create :organization }
    let(:user) { create(:user, organization: organization) }
    let(:component) { create(:component, permissions: permissions) }
    let(:resource) { nil }
    let(:action) { "vote" }
    let(:permissions) { { action => permission } }
    let(:name) { "dummy_authorization_handler" }
    let(:authorizer) { described_class.new(user, action, component, resource) }

    let!(:authorization) do
      create(:authorization, :granted, name: name, metadata: metadata)
    end

    let(:metadata) { { postal_code: "1234", location: "Tomorrowland" } }

    let(:response) { subject.authorize }

    let(:permission) do
      {
        "authorization_handler_name" => "dummy_authorization_handler",
        "options" => options
      }
    end

    let(:options) { {} }

    describe "authorized?" do
      context "when no permissions are set" do
        let(:permission) { {} }

        it "returns ok" do
          expect(response).to be_ok
        end
      end

      context "when the data is incomplete" do
        context "when the user is not logged in" do
          let(:user) { nil }

          it "returns missing" do
            expect(response).not_to be_ok
            expect(response.code).to eq(:missing)
            expect(response.handler_name).to eq("dummy_authorization_handler")
            expect(response.data).to eq(action: :authorize)
          end
        end

        context "when no component is provided" do
          let(:component) { nil }

          it "raises an exception" do
            expect { subject.authorize }.to raise_error(ActionAuthorizer::AuthorizationError)
          end
        end

        context "when an empty action is provided" do
          let(:action) { nil }

          it "raises an exception" do
            expect { subject.authorize }.to raise_error(ActionAuthorizer::AuthorizationError)
          end
        end
      end

      context "when the user has a valid authorization" do
        before { authorization.update!(user: user) }

        context "when the authorization has not expired" do
          before do
            allow(authorizer)
              .to receive(:authorization).and_return(authorization)
            allow(authorization)
              .to receive(:expired?).and_return(false)
          end

          context "when it doesn't have options" do
            let(:options) { {} }

            it "returns ok" do
              expect(response).to be_ok
            end
          end

          context "when has options that doesn't match the authorization" do
            let(:options) { { postal_code: "789" } }

            it "returns unauthorized" do
              expect(response).not_to be_ok
              expect(response.code).to eq(:unauthorized)
              expect(response.handler_name).to eq("dummy_authorization_handler")
              expect(response.data).to eq(fields: { "postal_code" => "789" })
            end
          end

          context "when has options that exactly match the authorization" do
            let(:options) { { postal_code: "1234", location: "Tomorrowland" } }

            it "returns ok" do
              expect(response).to be_ok
            end
          end

          context "when has options that partially match the authorization" do
            let(:options) { { postal_code: "1234" } }

            it "returns ok" do
              expect(response).to be_ok
            end
          end

          context "when has options that contains more keys than the authorization" do
            let(:options) { { postal_code: "1234", age: 18 } }

            it "returns incomplete with the fields" do
              expect(response).not_to be_ok
              expect(response.code).to eq(:incomplete)
              expect(response.handler_name).to eq("dummy_authorization_handler")
              expect(response.data).to include(fields: ["age"])
              expect(response.data).to include(action: :reauthorize)
              expect(response.data).to include(cancel: true)
            end
          end

          context "when custom action authorizer options are present and match the authorization" do
            let(:options) { { allowed_postal_codes: %w(1234 4567) } }

            it "returns ok" do
              expect(response).to be_ok
              expect(response.data).to include(extra_explanation: { key: "extra_explanation",
                                                                    params: { scope: "decidim.verifications.dummy_authorization",
                                                                              count: 2,
                                                                              postal_codes: "1234, 4567" } })
            end
          end

          context "when custom action authorizer options are present and don't match the authorization" do
            let(:options) { { allowed_postal_codes: %w(2345 4567) } }

            it "returns unauthorized" do
              expect(response.code).to eq(:unauthorized)
              expect(response.handler_name).to eq("dummy_authorization_handler")
              expect(response.data).to include(fields: { "postal_code" => "1234" })
              expect(response.data).to include(extra_explanation: { key: "extra_explanation",
                                                                    params: { scope: "decidim.verifications.dummy_authorization",
                                                                              count: 2,
                                                                              postal_codes: "2345, 4567" } })
            end
          end
        end

        context "when the authorization has expired" do
          let!(:authorization) do
            create(:authorization, :granted, name: name, metadata: metadata, granted_at: 2.months.ago)
          end

          before do
            allow(authorizer)
              .to receive(:authorization).and_return(authorization)
            allow(authorization)
              .to receive(:expired?).and_return(true)
          end

          it "returns expired" do
            expect(response).not_to be_ok
            expect(response.code).to eq(:expired)
            expect(response.handler_name).to eq("dummy_authorization_handler")
            expect(response.data).to eq(action: :authorize)
          end
        end

        context "when the authorization is not yet granted" do
          before { authorization.update!(granted_at: nil) }

          it "returns pending" do
            expect(response).not_to be_ok
            expect(response.code).to eq(:pending)
            expect(response.handler_name).to eq("dummy_authorization_handler")
          end
        end
      end

      context "when the user doesn't have a valid authorization" do
        let(:name) { "bar_handler" }

        it "returns missing" do
          expect(response).not_to be_ok
          expect(response.code).to eq(:missing)
          expect(response.handler_name).to eq("dummy_authorization_handler")
          expect(response.data).to eq(action: :authorize)
        end
      end

      context "when a resource is given" do
        before do
          allow(resource).to receive(:resource_permission).and_return(resource_permission)
        end

        let(:resource) { create(:dummy_resource, component: component) }
        let(:resource_permission) do
          double(
            Decidim::ResourcePermission,
            permissions: permissions_for_resource
          )
        end
        let(:permissions_for_resource) do
          {
            action_for_resource => {
              "authorization_handler_name" => "another_dummy_authorization_handler",
              "options" => {}
            }
          }
        end
        let(:action_for_resource) { action }

        it "uses resource permissions" do
          expect(response).not_to be_ok
          expect(response.code).to eq(:missing)
          expect(response.handler_name).to eq("another_dummy_authorization_handler")
          expect(response.data).to eq(action: :authorize)
        end

        context "when resources has no permissions for the given action" do
          let(:action_for_resource) { "other_#{action}" }

          it "uses component permissions" do
            expect(response).not_to be_ok
            expect(response.code).to eq(:missing)
            expect(response.handler_name).to eq("dummy_authorization_handler")
            expect(response.data).to eq(action: :authorize)
          end
        end

        context "when resources permissions are disabled" do
          before do
            component.settings = { resources_permissions_enabled: false }
            component.save!
          end

          it "uses component permissions" do
            expect(response).not_to be_ok
            expect(response.code).to eq(:missing)
            expect(response.handler_name).to eq("dummy_authorization_handler")
            expect(response.data).to eq(action: :authorize)
          end
        end
      end
    end
  end
end
