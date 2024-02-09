# frozen_string_literal: true

require "spec_helper"

describe Decidim::AdminLog::OAuthApplicationPresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:admin_log_resource) { create(:oauth_application, organization:) }
    let(:action) { "update" }
  end
end
