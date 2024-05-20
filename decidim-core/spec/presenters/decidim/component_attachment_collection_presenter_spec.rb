# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ComponentAttachmentCollectionPresenter, type: :helper do
    let(:presenter) { described_class.new(component) }
    let(:participatory_space) { create(:participatory_process) }

    let(:component) { create(:component, :published, participatory_space:) }
    let(:resource) { create(:dummy_resource, component:, published_at: Time.current) }
    let!(:document) { create(:attachment, :with_pdf, attached_to: resource) }
    let!(:image) { create(:attachment, attached_to: resource) }

    describe "#attachments" do
      subject { presenter.attachments }

      it { is_expected.to include(document) }
      it { is_expected.to include(image) }
    end

    describe "#documents" do
      subject { presenter.documents }

      it { is_expected.to include(document) }
      it { is_expected.not_to include(image) }
    end

    describe "#unused?" do
      subject { presenter.unused? }

      it { is_expected.to be false }

      context "when there are no documents" do
        let!(:document) { nil }

        it { is_expected.to be true }
      end
    end
  end
end
