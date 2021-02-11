# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::PendingActions do
  let(:pending_action) { create(:action) }
  let(:accepted_action) { create(:action, status: "accepted") }

  it "returns only actions with pending status" do
    expect(described_class.for).to match_array pending_action
    expect(described_class.for).not_to match_array accepted_action
  end
end
