# frozen_string_literal: true

require "spec_helper"

describe Decidim::ResourceLikedEvent do
  let(:resource) { create(:debate, title: generate_localized_title(:debate_title)) }
  let(:resource_type) { "Debate" }
  let(:resource_text) { resource.description }

  it_behaves_like "resource liked event"
end
