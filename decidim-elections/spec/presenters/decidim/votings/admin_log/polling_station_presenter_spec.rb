# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Votings::AdminLog::PollingStationPresenter, type: :helper do
    include_examples "present admin log entry" do
      let(:admin_log_resource) { create(:polling_station) }
      let(:action) { "create" }
    end
  end
end
