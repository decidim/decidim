# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::AdminLog::InitiativePresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:admin_log_resource) { create(:initiative, organization:) }
    let(:action) { "publish" }
  end
end
