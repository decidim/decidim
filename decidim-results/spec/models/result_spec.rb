# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Results
    describe Result do
      let(:result) { build :result }
      subject { result }

      it { is_expected.to be_valid }

      include_examples "has feature"
      include_examples "has scope"
      include_examples "has category"
      include_examples "has reference"

      describe "#users_to_notify_on_comment_created" do
        let!(:follows) { create_list(:follow, 3, followable: subject) }
        let(:followers) { follows.map(&:user) }
        let(:participatory_space) { subject.feature.participatory_space }
        let(:organization) { participatory_space.organization }
        let!(:participatory_process_admin) do
          user = create(:user, :confirmed, organization: organization)
          Decidim::ParticipatoryProcessUserRole.create!(
            role: :admin,
            user: user,
            participatory_process: participatory_space
          )
          user
        end

        it "returns the followers and the feature's participatory space admins" do
          expect(subject.users_to_notify_on_comment_created).to match_array(followers.concat([participatory_process_admin]))
        end
      end
    end
  end
end
