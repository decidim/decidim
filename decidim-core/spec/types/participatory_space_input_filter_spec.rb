# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/input_filter_examples"

module Decidim
  module Core
    describe ParticipatorySpaceInputFilter, type: :graphql do
      include_context "with a graphql class type"
      let(:type_class) { Decidim::Api::QueryType }
      let!(:models) { create_list(:participatory_process, 3, :published, organization: current_organization) }

      context "when filtered by published_at" do
        include_examples "collection has before/since input filter", "participatoryProcesses", "published"
      end
    end
  end
end
