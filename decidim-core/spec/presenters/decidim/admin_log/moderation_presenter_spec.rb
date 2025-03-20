# frozen_string_literal: true

require "spec_helper"

describe Decidim::AdminLog::ModerationPresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:component) { create(:component, manifest_name: "dummy", organization:) }
    let(:reportable) { create(:dummy_resource, component:) }
    let(:moderation) { create(:moderation, reportable:) }
    let(:admin_log_resource) { create(:report, moderation:) }
    let(:action) { "unreport" }
  end
end
