# frozen_string_literal: true

require "spec_helper"

describe Decidim::ResourceLikedEvent do
  let(:resource) { create(:proposal, :participant_author, title: { en: "My proposal" }) }
  let(:resource_type) { "Proposal" }
  let(:resource_text) { resource.body }

  it_behaves_like "resource liked event"
end
