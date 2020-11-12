# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    module AdminLog
      describe AssemblyPresenter, type: :helper do
        include_examples "present admin log entry" do
          let(:admin_log_resource) { create(:assembly, organization: organization) }
          let(:action) { "unpublish" }
        end
      end
    end
  end
end
