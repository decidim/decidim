# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::AdminLog::AssembliesTypePresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:admin_log_resource) { create(:assemblies_type, organization:) }
    let(:action) { "delete" }
  end
end
