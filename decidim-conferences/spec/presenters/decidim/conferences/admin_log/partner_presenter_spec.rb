# frozen_string_literal: true

require "spec_helper"

describe Decidim::Conferences::AdminLog::PartnerPresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:conference) { create(:conference, organization:) }
    let(:admin_log_resource) { create(:partner, conference:) }
    let(:action) { "delete" }
  end
end
