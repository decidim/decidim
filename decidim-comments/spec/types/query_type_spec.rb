# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim::Api
  describe QueryType do
    include_context "with a graphql class type"

    describe "session" do
      let(:query) { "{ session { user { name } } }" }

      context "when the user is logged in" do
        it "return current user data" do
          expect(response["session"]).to include("user" => { "name" => current_user.name })
        end
      end

      context "when the user is not logged in" do
        let!(:current_user) { nil }

        it "return a nil object" do
          expect(response["session"]).to be_nil
        end
      end
    end
  end
end
