# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::AdminLog::ProposalPresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:participatory_space) { create(:participatory_process, organization:) }
    let(:component) { create(:proposal_component, participatory_space:) }
    let(:admin_log_resource) { create(:proposal, component:) }
    let(:action) { "answer" }
  end
end
