# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ActionAuthorizer do
    subject { described_class.new(user, feature, action) }

    let(:user) { create(:user) }
    let(:feature) { create(:feature, permissions: permissions) }
    let(:action) { "vote" }
    let(:permissions) { { action => permission } }
    let(:name) { "dummy_authorization_handler" }

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
            expect(response.data).to be_empty
          end
        end

        context "when no feature is provided" do
          let(:feature) { nil }

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

      context "when the data is valid" do
        let(:permission) do
          {
            "authorization_handler_name" => "dummy_authorization_handler",
            "options" => options
          }
        end

        context "when the user doesn't have a valid authorization" do
          let(:name) { "bar_handler" }

          it "returns missing" do
            expect(response).not_to be_ok
            expect(response.code).to eq(:missing)
            expect(response.handler_name).to eq("dummy_authorization_handler")
            expect(response.data).to be_empty
          end
        end

        context "when the user has a valid authorization" do
          before { authorization.update!(user: user) }

          context "when it's not yet granted" do
            before { authorization.update!(granted_at: nil) }

            it "returns pending" do
              expect(response).not_to be_ok
              expect(response.code).to eq(:pending)
              expect(response.handler_name).to eq("dummy_authorization_handler")
            end
          end

          context "when the authorization type matches" do
            context "when it doesn't have options" do
              let(:options) { {} }

              it "returns ok" do
                expect(response).to be_ok
              end
            end

            context "when has options that doesn't match the authorization" do
              let(:options) { { postal_code: "789" } }

              it "returns invalid" do
                expect(response).not_to be_ok
                expect(response.code).to eq(:invalid)
                expect(response.handler_name).to eq("dummy_authorization_handler")
                expect(response.data).to include(fields: { "postal_code" => "789" })
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
              end
            end
          end
        end
      end
    end
  end
end
