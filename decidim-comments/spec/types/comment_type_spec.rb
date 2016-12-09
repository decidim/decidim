# frozen_string_literal: true
require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Comments
    describe CommentType do
      include_context "graphql type"

      let(:model) { FactoryGirl.create(:comment) }

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns its created_at field" do
          expect(response).to include("createdAt" => model.created_at.to_s)
        end
      end
    end
  end
end
