# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Comments
    describe CommentableMutationType do
      include_context "with a graphql class type"

      let(:participatory_process) { create(:participatory_process, :published, organization: current_organization) }
      let(:component) { create(:component, :published, participatory_space: participatory_process) }
      let(:model) { create(:dummy_resource, :published, component:) }
      let(:body) { "test" }
      let(:alignment) { 1 }

      describe "addComment" do
        let(:query) do
          "{ addComment(body: \"#{body}\", alignment: #{alignment}) { body } }"
        end

        it "calls CreateComment command" do
          params = { "comment" => { "body" => body, "alignment" => alignment, "commentable" => model } }
          context = { current_organization:, current_user:, current_component: model.component }
          expect(Decidim::Comments::CommentForm).to receive(:from_params).with(params).and_call_original
          expect_any_instance_of(Decidim::Comments::CommentForm) # rubocop:disable RSpec/AnyInstance
            .to receive(:with_context).with(context).and_call_original
          expect(Decidim::Comments::CreateComment).to receive(:call).with(
            an_instance_of(Decidim::Comments::CommentForm)
          ).and_call_original
          expect(response["addComment"]).to include("body" => body)
        end
      end
    end
  end
end
