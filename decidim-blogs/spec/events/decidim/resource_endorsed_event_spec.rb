# frozen_string_literal: true

require "spec_helper"

describe Decidim::ResourceEndorsedEvent do
  let(:resource) { create(:post, title: generate_localized_title(:blog_title)) }
  let(:resource_type) { "Post" }
  let(:resource_text) { resource.body }

  it_behaves_like "resource liked event"
end
