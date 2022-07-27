# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CommentForm do
      subject do
        described_class.from_params(
          attributes
        ).with_context(
          current_organization: organization,
          current_component: component
        )
      end

      let(:organization) { create(:organization) }
      let!(:component) { create(:component, organization:) }
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

        context "with carriage return characters that cause it to exceed" do
          let(:body) { "#{"c" * 500}\r\n#{"c" * 499}" }

          it { is_expected.to be_valid }
        end
      end

      context "when alignment is not present" do
        let(:alignment) { nil }

        it { is_expected.to be_valid }
      end

      context "when alignment is present and it is different from 0, 1 and -1" do
        let(:alignment) { 2 }

        it { is_expected.not_to be_valid }
      end

      describe "#max_length" do
        context "when organization has a max length > 0" do
          let(:body) { "c" * 1001 }
          let(:organization) { create(:organization, comments_max_length: 1001) }

          it { is_expected.to be_valid }
        end

        context "when component has a max length > 0" do
          let(:body) { "c" * 1001 }

          before do
            component.update!(settings: { comments_max_length: 1001 })
          end

          it { is_expected.to be_valid }
        end

        context "when component is missing" do
          let!(:component) { nil }
          let(:body) { "c" * 1000 }

          it { is_expected.to be_valid }
        end

        context "when the component settings do not define comments_max_length" do
          let(:organization) { create(:organization, comments_max_length: 3549) }
          let(:settings) { double }

          it "returns the organization comments_max_length" do
            allow(component).to receive(:settings).and_return(settings)
            expect(subject.max_length).to eq(organization.comments_max_length)
          end
        end
      end
    end
  end
end
