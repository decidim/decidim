# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcesses::AdminLog::ParticipatoryProcessGroupPresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:admin_log_resource) { create(:participatory_process_group, organization:) }
    let(:action) { "unpublish" }
  end
end
