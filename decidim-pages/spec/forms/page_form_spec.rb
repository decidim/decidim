# frozen_string_literal: true

require "spec_helper"

describe Decidim::Pages::Admin::PageForm do
  subject do
    described_class.from_params(attributes).with_context(
      current_organization: current_organization
    )
  end

  let(:current_organization) { create(:organization) }
  let(:attachment_params) { nil }

  let(:body) do
    {
      en: "<p>Content</p>",
      ca: "<p>Contingut</p>",
      es: "<p>Contenido</p>"
    }
  end

  let(:commentable) { true }

  let(:attributes) do
    {
      page: {
        body: body,
        commentable: commentable,
        attachment: attachment_params
      }
    }
  end

  context "when everything is OK" do
    it { is_expected.to be_valid }
  end
end
