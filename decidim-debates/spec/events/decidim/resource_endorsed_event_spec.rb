# frozen_string_literal: true

require "spec_helper"

describe Decidim::ResourceEndorsedEvent do
  let(:resource) { create :debate, title: { en: "My debate" } }
  let(:resource_type) { "Debate" }
  let(:resource_text) { resource.description }

  it_behaves_like "resource endorsed event"
end
