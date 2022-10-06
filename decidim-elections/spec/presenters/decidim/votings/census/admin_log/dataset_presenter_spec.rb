# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Votings::Census::AdminLog::DatasetPresenter, type: :helper do
    include_examples "present admin log entry" do
      let(:voting) { create(:voting, organization:) }
      let(:admin_log_resource) { create(:dataset, voting:) }
      let(:action) { "create" }
    end

    include_examples "present admin log entry" do
      let(:voting) { create(:voting, organization:) }
      let(:admin_log_resource) { create(:dataset, voting:) }
      let(:action) { "delete" }
    end
  end
end
