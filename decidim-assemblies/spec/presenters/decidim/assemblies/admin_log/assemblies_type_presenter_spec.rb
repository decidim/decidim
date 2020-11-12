# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    module AdminLog
      describe AssembliesTypePresenter, type: :helper do
        include_examples "present admin log entry" do
          let(:admin_log_resource) { create(:assemblies_type, organization: organization) }
          let(:action) { "delete" }
        end
      end
    end
  end
end
