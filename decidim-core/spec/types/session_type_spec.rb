# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe SessionType do
      include_context "with a graphql class type"

      let(:model) { current_user }

      describe "user" do
        let(:query) { "{ user { nickname } }" }

        it "returns the current user" do
          expect(response["user"]["nickname"]).to eq("@#{model.nickname}")
        end
      end
    end
  end
end
