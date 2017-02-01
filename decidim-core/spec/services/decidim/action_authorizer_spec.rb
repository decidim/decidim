# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe ActionAuthorizer do
    let(:user) { double }
    let(:feature) { double(permissions: permissions) }
    let(:action) { "vote" }
    let(:permissions) { {action => permission} }
    let(:permission) { {} }
    let(:authorization) { double(metadata: metadata) }
    let(:metadata) { { postal_code: "1234", location: "Tomorrowland" } }

    let(:user) { create(:user) }
    subject { described_class.new(user, feature, action) }

    describe "authorized?" do
      context "when the data is incomplete" do
        context "when the user is not logged in" do
          let(:user) { nil }

          it "raises an exception" do
            expect { subject.authorize }.to raise_error(ActionAuthorizer::AuthorizationError)
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
        before do
          authorizations = double

          allow(user).to(
            receive(:authorizations)
          ).and_return authorizations

          allow(authorizations).to(
            receive(:find_by).with(name: "foo_handler")
          ).and_return authorization
        end

        let(:permission) do
          {
            "authorization_handler_name" => "foo_handler",
            "options" => options
          }
        end

        let(:options) { {} }

        context "when the user doesn't have a valid authorization" do
          let(:authorization) { nil }

          it "broadcasts missing" do
            expect{ subject.authorize }.to broadcast(:missing, "foo_handler")
          end
        end

        context "when the authorization type matches" do
          context "when it doesn't have options" do
            let(:options) { {} }

            it "broadcasts ok" do
              expect { subject.authorize }.to broadcast(:ok)
            end
          end

          context "when has options that doesn't match the authorization" do
            let(:options) { { postal_code: "789" } }

            it "broadcasts invalid" do
              expect { subject.authorize }.to broadcast(:invalid, "foo_handler", [:postal_code])
            end
          end

          context "when has options that exactly match the authorization" do
            let(:options) { { postal_code: "1234", location: "Tomorrowland" } }

            it "broadcasts ok" do
              expect { subject.authorize }.to broadcast(:ok)
            end
          end

          context "when has options that partially match the authorization" do
            let(:options) { { postal_code: "1234" } }

            it "broadcasts ok" do
              expect { subject.authorize }.to broadcast(:ok)
            end
          end

          context "when has options that contains more keys than the authorization" do
            let(:options) { { postal_code: "1234", age: 18 } }

            it "broadcasts incomplete with the fields" do
              expect { subject.authorize }.to broadcast(:incomplete, "foo_handler", [:age])
            end
          end
        end
      end
    end
  end
end
