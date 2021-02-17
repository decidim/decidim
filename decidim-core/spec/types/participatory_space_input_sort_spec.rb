# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/input_sort_examples"

module Decidim
  module Core
    describe ParticipatorySpaceInputSort, type: :graphql do
      include_context "with a graphql class type"
      let(:type_class) { Decidim::Api::QueryType }
      let!(:models) { create_list(:participatory_process, 3, :published, organization: current_organization) }

      context "when sorting by participatory process id" do
        include_examples "collection has input sort", "participatoryProcesses", "id"
      end

      context "when sorting by participatory process published_at" do
        include_examples "collection has input sort", "participatoryProcesses", "publishedAt"
      end
    end
  end
end
