# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings
  describe CertifyPollingStationClosure do
    subject { described_class.new(form, closure) }

    let(:closure) { create :ps_closure, :with_results, phase: :certificate }
    let(:add_photos) { [upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg"))] }

    let(:form) { ClosureCertifyForm.from_params(add_photos:).with_context(closure:) }

    it "saves the attachment" do
      expect { subject.call }.to change(Decidim::Attachment, :count).by(1)
      expect(closure.photos.first).to be_present
      expect(closure.photos.first).to be_kind_of(Decidim::Attachment)
    end

    it "changes to signature phase" do
      subject.call

      expect(closure.signature_phase?).to be true
    end
  end
end
