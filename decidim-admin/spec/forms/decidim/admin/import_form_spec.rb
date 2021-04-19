# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ImportForm do
      subject { form }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:file) { Decidim::Dev.test_file("import_proposals.csv", "text/csv") }
      let(:another_file) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
      let(:creator) { Decidim::Admin::Import::Creator }

      let(:params) { { file: file, creator: creator } }

      let(:form) do
        described_class.from_params(params).with_context(
          current_organization: organization
        )
      end

      context "when everything is OK" do
        it do
          allow(form).to receive(:check_invalid_lines).and_return([])
          expect(subject).to be_valid
        end
      end

      context "when content type is not accepted" do
        let(:params) { { file: another_file, creator: creator } }

        it { is_expected.not_to be_valid }
      end

      describe "#creator_class" do
        it "returns creators class" do
          expect(subject.creator_class).to eq(creator)
        end
      end
    end
  end
end
