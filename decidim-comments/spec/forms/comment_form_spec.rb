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
          current_component: component,
          current_user: user
        )
      end

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, organization:) }
      let!(:component) { create(:component, participatory_space: assembly) }
      let(:assembly) { create(:assembly, organization:) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:another_assembly) { create(:assembly, organization:) }
      let(:body) { "This is a new comment" }
      let(:alignment) { 1 }

      let(:commentable) { create(:dummy_resource) }

      let(:attributes) do
        {
          "comment" => {
            "body" => body,
            "alignment" => alignment,
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

      shared_examples "allows commenting" do
        it "allows commenting" do
          expect(subject.send(:commentable_can_have_comments)).to be_nil
          expect(subject).to be_valid
        end
      end

      shared_examples "does not allow commenting" do
        it "does not allow comments" do
          expect(subject.send(:commentable_can_have_comments)).not_to be_nil
          expect(subject).not_to be_valid
        end
      end

      describe "#commentable_can_have_comments" do
        let(:accepts_new_comments) { true }

        before do
          allow(commentable).to receive(:accepts_new_comments?).and_return(accepts_new_comments)
        end

        it_behaves_like "allows commenting"

        context "when no comments are accepted" do
          let!(:accepts_new_comments) { false }

          it_behaves_like "does not allow commenting"

          context "when user is admin" do
            let(:user) { create(:user, :admin, :confirmed, organization:) }

            it_behaves_like "allows commenting"
          end

          context "when user is user manager" do
            let(:user) { create(:user, :user_manager, :confirmed, organization:) }

            it_behaves_like "allows commenting"
          end

          context "when user is moderator in the same participatory space" do
            let!(:moderator_role) { create(:assembly_user_role, user:, assembly:, role: :moderator) }

            it_behaves_like "allows commenting"
          end

          context "when user is moderator in another participatory space" do
            let!(:moderator_role) { create(:participatory_process_user_role, user:, participatory_process:, role: :moderator) }

            it_behaves_like "does not allow commenting"
          end

          context "when user is moderator in another assembly" do
            let!(:moderator_role) { create(:assembly_user_role, user:, assembly: another_assembly, role: :moderator) }

            it_behaves_like "does not allow commenting"
          end
        end
      end
    end
  end
end
