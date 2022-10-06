# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ActionAuthorizer do
    subject { authorizer }

    let(:organization) { create(:organization, available_authorizations: %w(dummy_authorization_handler another_dummy_authorization_handler)) }
    let(:user) { create(:user, organization:) }
    let(:component) { create(:component, permissions:, organization:) }
    let(:resource) { nil }
    let(:action) { "vote" }
    let(:permissions) { { action => permission } }
    let(:name) { "dummy_authorization_handler" }
    let(:authorizer) { described_class.new(user, action, component, resource) }

    let!(:authorization) do
      create(:authorization, :granted, name:, metadata:)
    end

    let(:metadata) { { postal_code: "1234", location: "Tomorrowland" } }

    let(:response) { subject.authorize }

    let(:permission) do
      {
        "authorization_handlers" => {
          "dummy_authorization_handler" => { "options" => options }
        }
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

      context "when one authorization handler is set" do
        let(:permission) do
          {
            "authorization_handler_name" => name,
            "options" => options
          }
        end

        context "when authorization is granted" do
          before { authorization.update!(user:, granted_at: 1.minute.ago) }

          it "returns an authorization status ok" do
            expect(response).to be_ok
            expect(response.statuses.count).to eq(1)
            expect(response.codes).to include(:ok)
          end
        end

        context "when authorization is not granted" do
          before { authorization.update!(user:, granted_at: nil) }

          it "returns an authorization status not ok" do
            expect(response).not_to be_ok
            expect(response.statuses.count).to eq(1)
            expect(response.codes).to include(:pending)
          end
        end
      end

      context "when more than one authorization handlers are set" do
        let!(:another_authorization) do
          create(:authorization, :granted, name: "another_dummy_authorization_handler", metadata:)
        end
        let(:permission) do
          {
            "authorization_handlers" => {
              "dummy_authorization_handler" => { "options" => options },
              "another_dummy_authorization_handler" => { "options" => {} }
            }
          }
        end

        context "when the user only has a valid authorization" do
          before { authorization.update!(user:, granted_at: 1.minute.ago) }

          context "when only one authorzation matches options" do
            it "returns an authorization status not ok" do
              expect(response).not_to be_ok
              expect(response.statuses.count).to eq(2)
              expect(response.codes).to include(:ok)
            end
          end

          context "when both authorizations are ok" do
            before { another_authorization.update!(user:, granted_at: 1.minute.ago) }

            it "returns an ok authorization status" do
              expect(response).to be_ok
              expect(response.statuses.count).to eq(2)
              expect(response.codes).to include(:ok)
            end
          end

          context "when options doesn't match one authorization" do
            let(:options) { { postal_code: "789" } }

            it "returns an authorization status collection including unauthorized" do
              expect(response).not_to be_ok
              expect(response.statuses.count).to eq(2)
              expect(response.codes).to include(:unauthorized)
            end
          end
        end
      end

      context "when organization doesnt have authorization handler available" do
        let(:permission) do
          {
            "authorization_handlers" => {
              "disabled_authorization_handler" => {}
            }
          }
        end

        it "doesn't require it" do
          expect(response).to be_ok
          expect(response.statuses.count).to eq(0)
        end
      end

      context "when the data is incomplete" do
        context "when the user is not logged in" do
          let(:user) { nil }

          it "returns an authorization status collection including missing" do
            expect(response).not_to be_ok
            expect(response.statuses.count).to eq(1)
            expect(response.codes).to include(:missing)
            authorizer = response.statuses.first
            expect(authorizer.code).to eq(:missing)
            expect(authorizer.handler_name).to eq("dummy_authorization_handler")
            expect(authorizer.data).to eq(action: :authorize)
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
        before { authorization.update!(user:) }

        context "when the authorization has not expired" do
          before { authorization.update!(granted_at: 1.minute.ago) }

          context "when it doesn't have options" do
            let(:options) { {} }

            it "returns ok" do
              expect(response).to be_ok
            end
          end

          context "when has options that doesn't match the authorization" do
            let(:options) { { postal_code: "789" } }

            it "returns an authorization status collection including unauthorized" do
              expect(response).not_to be_ok
              expect(response.statuses.count).to eq(1)
              expect(response.codes).to include(:unauthorized)
              authorizer = response.statuses.first
              expect(authorizer.code).to eq(:unauthorized)
              expect(authorizer.handler_name).to eq("dummy_authorization_handler")
              expect(authorizer.data).to eq(fields: { "postal_code" => "789" })
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

            it "returns an authorization status collection including incomplete with the fields" do
              expect(response).not_to be_ok
              expect(response.statuses.count).to eq(1)
              expect(response.codes).to include(:incomplete)
              authorizer = response.statuses.first
              expect(authorizer.code).to eq(:incomplete)
              expect(authorizer.handler_name).to eq("dummy_authorization_handler")
              expect(authorizer.data).to include(fields: ["age"])
              expect(authorizer.data).to include(action: :reauthorize)
              expect(authorizer.data).to include(cancel: true)
            end
          end

          context "when custom action authorizer options are present and match the authorization" do
            let(:options) { { allowed_postal_codes: "1234 4567" } }

            it "returns ok" do
              expect(response).to be_ok
              expect(response.statuses.count).to eq(1)
              authorizer = response.statuses.first
              expect(authorizer.data).not_to include(extra_explanation: [])
            end
          end

          context "when custom action authorizer options are present and don't match the authorization" do
            let(:options) { { allowed_postal_codes: "2345,4567" } }

            it "returns an authorization status collection including unauthorized" do
              expect(response.statuses.count).to eq(1)
              expect(response.codes).to include(:unauthorized)
              authorizer = response.statuses.first
              expect(authorizer.code).to eq(:unauthorized)
              expect(authorizer.handler_name).to eq("dummy_authorization_handler")
              expect(authorizer.data).to include(extra_explanation: [{ key: "extra_explanation.user_postal_codes",
                                                                       params: { scope: "decidim.verifications.dummy_authorization",
                                                                                 count: 2,
                                                                                 postal_codes: "2345, 4567",
                                                                                 user_postal_code: "1234" } }])
            end
          end

          context "when options are present but empty" do
            let(:options) { { postal_code: "" } }

            it "returns ok" do
              expect(response).to be_ok
            end
          end

          context "when attribute is defined in manifest with required_for_authorization" do
            before do
              Verifications.find_workflow_manifest(name).options do |opts|
                opts.attribute :location, type: :string, required: false, required_for_authorization:
              end
            end

            context "when options are empty" do
              let(:options) { {} }

              context "and required_for_authorization is true" do
                let(:required_for_authorization) { true }

                context "and metadata is empty" do
                  let(:metadata) { {} }

                  it "returns incomplete" do
                    expect(response.codes).to include(:incomplete)
                  end
                end

                context "and metadata contains a value for the attribute" do
                  let(:metadata) { { location: "Tomorrowland" } }

                  it "returns ok" do
                    expect(response).to be_ok
                  end
                end
              end

              context "and required_for_authorization is false" do
                let(:required_for_authorization) { false }

                context "and metadata is empty" do
                  let(:metadata) { {} }

                  it "returns ok" do
                    expect(response).to be_ok
                  end
                end
              end
            end
          end
        end

        context "when the authorization has expired" do
          let!(:authorization) do
            create(:authorization, :granted, name:, metadata:, granted_at: 2.months.ago)
          end

          before do
            allow(authorizer)
              .to receive(:authorization).and_return(authorization)
            allow(authorization)
              .to receive(:expired?).and_return(true)
          end

          it "returns an authorization status collection including expired" do
            expect(response).not_to be_ok
            expect(response.statuses.count).to eq(1)
            expect(response.codes).to include(:expired)
            authorizer = response.statuses.first
            expect(authorizer.code).to eq(:expired)
            expect(authorizer.handler_name).to eq("dummy_authorization_handler")
            expect(authorizer.data).to eq(action: :authorize)
          end
        end

        context "when the authorization is not yet granted" do
          before { authorization.update!(granted_at: nil) }

          it "returns an authorization status collection including pending" do
            expect(response).not_to be_ok
            expect(response.statuses.count).to eq(1)
            expect(response.codes).to include(:pending)
            authorizer = response.statuses.first
            expect(authorizer.code).to eq(:pending)
            expect(authorizer.handler_name).to eq("dummy_authorization_handler")
          end
        end
      end

      context "when the user doesn't have a valid authorization" do
        let(:name) { "bar_handler" }

        it "returns an authorization status collection including missing" do
          expect(response).not_to be_ok
          expect(response.statuses.count).to eq(1)
          expect(response.codes).to include(:missing)
          authorizer = response.statuses.first
          expect(authorizer.code).to eq(:missing)
          expect(authorizer.handler_name).to eq("dummy_authorization_handler")
          expect(authorizer.data).to eq(action: :authorize)
        end
      end

      context "when a resource is given" do
        before do
          allow(resource).to receive(:resource_permission).and_return(resource_permission)
        end

        let(:resource) { create(:dummy_resource, component:) }
        let(:resource_permission) do
          double(
            Decidim::ResourcePermission,
            permissions: permissions_for_resource
          )
        end
        let(:permissions_for_resource) do
          {
            action_for_resource => {
              "authorization_handlers" => {
                "another_dummy_authorization_handler" => { "options" => {} }
              }
            }
          }
        end
        let(:action_for_resource) { action }

        it "uses resource permissions" do
          expect(response).not_to be_ok
          expect(response.statuses.count).to eq(1)
          expect(response.codes).to include(:missing)
          authorizer = response.statuses.first
          expect(authorizer.code).to eq(:missing)
          expect(authorizer.handler_name).to eq("another_dummy_authorization_handler")
          expect(authorizer.data).to eq(action: :authorize)
        end

        context "when resources has no permissions for the given action" do
          let(:action_for_resource) { "other_#{action}" }

          it "uses component permissions" do
            expect(response).not_to be_ok
            expect(response.statuses.count).to eq(1)
            expect(response.codes).to include(:missing)
            authorizer = response.statuses.first
            expect(authorizer.code).to eq(:missing)
            expect(authorizer.handler_name).to eq("dummy_authorization_handler")
            expect(authorizer.data).to eq(action: :authorize)
          end
        end

        context "when resources permissions are disabled" do
          before do
            component.settings = { resources_permissions_enabled: false }
            component.save!
          end

          it "uses component permissions" do
            expect(response).not_to be_ok
            expect(response.statuses.count).to eq(1)
            expect(response.codes).to include(:missing)
            authorizer = response.statuses.first
            expect(authorizer.code).to eq(:missing)
            expect(authorizer.handler_name).to eq("dummy_authorization_handler")
            expect(authorizer.data).to eq(action: :authorize)
          end
        end
      end
    end
  end
end
