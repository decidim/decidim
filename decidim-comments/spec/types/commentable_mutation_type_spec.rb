# frozen_string_literal: true
require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Comments
    describe CommentableMutationType do
      include_context "graphql type"

      let(:participatory_process) { create(:participatory_process, organization: current_organization) }
      let(:feature) { create(:feature, participatory_process: participatory_process) }
      let(:model) { create(:dummy_resource, feature: feature) }
      let(:body) { "test" }
      let(:alignment) { 1 }

      describe "addComment" do
        let(:query) {
          "{ addComment(body: \"#{body}\", alignment: #{alignment}) { body } }"
        }

        it "calls CreateComment command" do
          params = { "comment" => { "body" => body, "alignment" => alignment, "user_group_id" => nil } }
          expect(Decidim::Comments::CommentForm).to receive(:from_params).with(params).and_call_original
          expect(Decidim::Comments::CreateComment).to receive(:call).with(
            an_instance_of(Decidim::Comments::CommentForm),
            current_user,
            model
          ).and_call_original
          expect(response["addComment"]).to include("body" => body)
        end
      end
    end
  end
end
