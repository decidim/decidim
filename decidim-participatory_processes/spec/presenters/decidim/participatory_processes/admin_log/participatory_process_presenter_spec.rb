# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcesses::AdminLog::ParticipatoryProcessPresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:admin_log_resource) { create(:participatory_process, organization:) }
    let(:action) { "unpublish" }
  end
end
