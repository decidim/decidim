# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe CollaborativeDraft do
      subject { collaborative_draft }

      let(:organization) { component.participatory_space.organization }
      let(:component) { create :proposal_component }
      let(:collaborative_draft) { create(:collaborative_draft, component:) }
      let(:coauthorable) { collaborative_draft }

      include_examples "coauthorable"
      include_examples "has scope"
      include_examples "has category"
      include_examples "resourceable"

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      describe "#users_to_notify_on_comment_created" do
        let!(:follows) { create_list(:follow, 3, followable: subject) }
        let(:followers) { follows.map(&:user) }
        let(:participatory_space) { subject.component.participatory_space }
        let(:organization) { participatory_space.organization }
        let!(:participatory_process_admin) do
          create(:process_admin, participatory_process: participatory_space)
        end

        it "returns the followers" do
          expect(subject.users_to_notify_on_comment_created).to match_array(followers.push(collaborative_draft.creator_author))
        end
      end

      describe "#editable_by?" do
        let(:author) { create(:user, organization:) }

        context "when user is author" do
          let(:collaborative_draft) do
            cd = create :collaborative_draft, component: component, updated_at: Time.current
            Decidim::Coauthorship.create(author:, coauthorable: cd)
            cd
          end

          it { is_expected.to be_editable_by(author) }
        end

        context "when created from user group and user is admin" do
          let(:user_group) { create :user_group, :verified, users: [author], organization: author.organization }
          let(:collaborative_draft) do
            cd = create :collaborative_draft, component: component, updated_at: Time.current
            Decidim::Coauthorship.create(author:, decidim_user_group_id: user_group.id, coauthorable: cd)
            cd
          end

          it { is_expected.to be_editable_by(author) }
        end

        context "when user is not the author" do
          let(:collaborative_draft) { create :collaborative_draft, component:, updated_at: Time.current }

          it { is_expected.not_to be_editable_by(author) }
        end
      end
    end
  end
end
