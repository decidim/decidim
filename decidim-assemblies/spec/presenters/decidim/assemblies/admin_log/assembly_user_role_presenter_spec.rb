# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::AdminLog::AssemblyUserRolePresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:admin_log_resource) { create(:assembly_user_role, user:) }
    let(:action) { "delete" }
  end
end
