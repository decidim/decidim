# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentForm do
      subject do
        described_class.from_params(
          attributes
        )
      end

      let(:body) { "This is a new comment" }
      let(:alignment) { 1 }
      let(:user_group) { create(:user_group, :verified) }
      let(:user_group_id) { user_group.id }

      let(:commentable) { create :dummy_resource }

      let(:attributes) do
        {
          "comment" => {
            "body" => body,
            "alignment" => alignment,
            "user_group_id" => user_group_id,
            "commentable" => commentable
          }
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when body is blank" do
        let(:body) { "" }

        it { is_expected.not_to be_valid }
      end

      context "when body is too long" do
        let(:body) { "c" * 1001 }

        it { is_expected.not_to be_valid }
      end

      context "when alignment is not present" do
        let(:alignment) { nil }

        it { is_expected.to be_valid }
      end

      context "when alignment is present and it is different from 0, 1 and -1" do
        let(:alignment) { 2 }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
