# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/has_publishable_input_sort"

module Decidim
  module Core
    describe ParticipatorySpaceInputSort, type: :graphql do
      include_context "with a graphql type"
      let(:type_class) { Decidim::Api::QueryType }
      let!(:model) { create_list(:participatory_process, 3, :published, organization: current_organization) }

      include_examples "has publishable input sort", "ParticipatoryProcessSort", "participatoryProcesses"
    end
  end
end
