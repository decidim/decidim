# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Votings::AdminLog::VotingPresenter, type: :helper do
    include_examples "present admin log entry" do
      let(:admin_log_resource) { create(:voting, organization:) }
      let(:action) { "unpublish" }
    end
  end
end
