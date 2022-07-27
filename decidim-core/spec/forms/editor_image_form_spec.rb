# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe EditorImageForm do
    subject { described_class.from_params(attributes).with_context(context) }

    let(:attributes) do
      {
        "editor_image" => {
          organization:,
          author_id: user_id,
          file:
        }
      }
    end
    let(:context) do
      {
        current_organization: organization,
        current_user: user
      }
    end
    let(:user) { create(:user, :admin, :confirmed) }
    let(:organization) { user.organization }
    let(:user_id) { user.id }
    let(:file) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

    context "with correct data" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "with an empty user_id" do
      let(:user_id) { nil }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end

    context "with an empty organization" do
      let(:organization) { nil }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end

    context "when images are not the expected type" do
      let(:file) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }

      it { is_expected.not_to be_valid }
    end
  end
end
