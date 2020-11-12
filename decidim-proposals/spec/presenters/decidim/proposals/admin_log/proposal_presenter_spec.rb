# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module AdminLog
      describe ProposalPresenter, type: :helper do
        include_examples "present admin log entry" do
          let(:participatory_space) { create(:participatory_process, organization: organization) }
          let(:component) { create(:proposal_component, participatory_space: participatory_space) }
          let(:admin_log_resource) { create(:proposal, component: component) }
          let(:action) { "answer" }
        end
      end
    end
  end
end
