# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::AdminLog::AssemblyPresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:admin_log_resource) { create(:assembly, organization:) }
    let(:action) { "unpublish" }
  end
end
