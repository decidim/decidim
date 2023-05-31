# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::AdminLog::AssemblyMemberPresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:assembly) { create(:assembly, organization:) }
    let(:admin_log_resource) { create(:assembly_member, assembly:) }
    let(:action) { "delete" }
  end
end
