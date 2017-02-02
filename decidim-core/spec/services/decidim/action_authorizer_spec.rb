# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe ActionAuthorizer do
    let(:user) { double(authorizations: [authorization]) }
    let(:feature) { double(permissions: permissions) }
    let(:action) { "vote" }
    let(:permissions) { {action => permission} }
    let(:permission) { {} }
    let(:authorization) { double(name: "foo_handler", metadata: metadata) }
    let(:metadata) { { postal_code: "1234", location: "Tomorrowland" } }
    let(:response) { subject.authorize }

    let(:permission) do
      {
        "authorization_handler_name" => "foo_handler",
        "options" => options
      }
    end

    let(:options) { {} }

    subject { described_class.new(user, feature, action) }

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
            expect(response).to_not be_ok
            expect(response.code).to eq(:missing)
            expect(response.data).to include(handler: "foo_handler")
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
            "authorization_handler_name" => "foo_handler",
            "options" => options
          }
        end

        context "when the user doesn't have a valid authorization" do
          let(:authorization) { double(name: "bar_handler") }

          it "returns missing" do
            expect(response).to_not be_ok
            expect(response.code).to eq(:missing)
            expect(response.data).to include(handler: "foo_handler")
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
              expect(response).to_not be_ok
              expect(response.code).to eq(:invalid)
              expect(response.data).to include(fields: [:postal_code])
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
              expect(response).to_not be_ok
              expect(response.code).to eq(:incomplete)
              expect(response.data).to include(handler: "foo_handler", fields: [:age])
            end
          end
        end
      end
    end
  end
end
