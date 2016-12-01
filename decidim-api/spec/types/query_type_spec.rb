# frozen_string_literal: true
require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Api
    describe QueryType do
      include_context "graphql type"

      describe "processes" do
        let!(:process1) { create(:participatory_process, organization: current_organization) }
        let!(:process2) { create(:participatory_process, organization: current_organization) }
        let!(:process3) { create(:participatory_process) }

        let(:query) { %({ processes { id }}) }

        it "returns all the processes" do
          expect(response["processes"]).to     include("id" => process1.id.to_s)
          expect(response["processes"]).to     include("id" => process2.id.to_s)
          expect(response["processes"]).to_not include("id" => process3.id.to_s)
        end
      end

      describe "comments" do
        let!(:participatory_process_1) { create(:participatory_process, organization: current_organization) }
        let!(:comment_1) { create(:comment, commentable: participatory_process_1) }
        let!(:participatory_process_2) { create(:participatory_process, organization: current_organization) }
        let!(:comment_2) { create(:comment, commentable: participatory_process_2) }

        let(:query) { "{ comments(commentableId: \"#{participatory_process_1.id.to_s}\", commentableType: \"Decidim::ParticipatoryProcess\") { id } }" }

        it "returns comments from a commentable resource" do
          expect(response["comments"]).to     include("id" => comment_1.id.to_s)
          expect(response["comments"]).to_not include("id" => comment_2.id.to_s)
        end
      end
    end
  end
end
