# frozen_string_literal: true
require 'spec_helper'
require "decidim/api/test/type_context"

module Decidim
  module Comments
    describe AuthorType do
      include_context "graphql type"
      
      let(:model) { FactoryGirl.create(:user) }

      describe "avatarUrl" do
        let (:query) { "{ avatarUrl }" }

        it "returns the user avatar url" do
          expect(response).to include("avatarUrl" => model.avatar.url)
        end
      end
    end
  end
end