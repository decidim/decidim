# frozen_string_literal: true

require "spec_helper"

describe Decidim::Conferences::AdminLog::ConferencePresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:admin_log_resource) { create(:conference, organization:) }
    let(:action) { "unpublish" }
  end
end
