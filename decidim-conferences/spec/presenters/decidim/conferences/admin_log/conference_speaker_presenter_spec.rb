# frozen_string_literal: true

require "spec_helper"

describe Decidim::Conferences::AdminLog::ConferenceSpeakerPresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:conference) { create(:conference, organization:) }
    let(:admin_log_resource) { create(:conference_speaker, conference:) }
    let(:action) { "delete" }
  end
end
