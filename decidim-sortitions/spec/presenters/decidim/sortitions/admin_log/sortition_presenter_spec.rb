# frozen_string_literal: true

require "spec_helper"

describe Decidim::Sortitions::AdminLog::SortitionPresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:participatory_space) { create(:participatory_process, organization: organization) }
    let(:component) { create(:sortition_component, participatory_space: participatory_space) }
    let(:admin_log_resource) { create(:sortition, component: component) }
    let(:action) { "delete" }
  end
end
