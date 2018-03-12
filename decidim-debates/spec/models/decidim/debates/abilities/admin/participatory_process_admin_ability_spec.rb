# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Abilities::Admin::ParticipatoryProcessAdminAbility do
  subject { described_class.new(user, context) }

  let(:user) { build(:user) }
  let(:user_process) { create :participatory_process, organization: user.organization }
  let!(:user_process_role) { create :participatory_process_user_role, user: user, participatory_process: user_process, role: :admin }
  let(:component) { create :debate_component, participatory_space: user_process }
  let(:debates) { create_list :debate, 3, component: component }
  let(:other_debates) { create_list :debate, 3 }
  let(:context) { { current_participatory_space: user_process } }

  context "when the user is an admin" do
    let(:user) { build(:user, :admin) }

    it "doesn't have any permission" do
      expect(subject.permissions[:can]).to be_empty
      expect(subject.permissions[:cannot]).to be_empty
    end
  end

  it { is_expected.to be_able_to(:manage, Decidim::Debates::Debate) }
  it { is_expected.to be_able_to(:hide, Decidim::Debates::Debate) }
  it { is_expected.to be_able_to(:unreport, Decidim::Debates::Debate) }

  context "when the debate is from a user" do
    let(:debate) { build :debate, :with_author }

    it { is_expected.not_to be_able_to(:manage, debate) }
  end
end
