# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/has_publishable_input_filter"

module Decidim
  module Core
    describe ParticipatorySpaceInputFilter, type: :graphql do
      include_context "with a graphql type"
      let(:type_class) { Decidim::Api::QueryType }

      include_examples "has publishable input filter", "ParticipatoryProcessFilter", "participatoryProcesses"
    end
  end
end
