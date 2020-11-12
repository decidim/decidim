# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    module AdminLog
      describe AdminLog::AssemblyMemberPresenter, type: :helper do
        include_examples "present admin log entry" do
          let(:assembly) { create(:assembly, organization: organization) }
          let(:admin_log_resource) { create(:assembly_member, assembly: assembly) }
          let(:action) { "delete" }
        end
      end
    end
  end
end
