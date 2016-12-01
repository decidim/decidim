# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Comments
    describe CommentForm do
      let(:organization) { create :organization }
      let(:author) { create :user, organization: organization }
      let(:participatory_process) { create :participatory_process, organization: organization }
      let(:body) { "This is a new comment" }
      
      let(:attributes) do
        {
          "comment" => {
            "body" => body
          }
        }
      end

      subject do
        described_class.from_params(
          attributes,
          author: author,
          commentable: participatory_process,
        )
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when author is not set" do
        let(:author) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when commentable is not set" do
        let(:participatory_process) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when body is blank" do
        let(:body) { "" }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
