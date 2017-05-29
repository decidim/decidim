# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::Abilities::ProcessAdminUser do
  let(:user) { build(:user) }
  let(:user_process) { create :participatory_process, organization: user.organization }
  let(:context) { {} }

  subject { described_class.new(user, context) }

  context "when the user is an admin" do
    let(:user) { build(:user, :admin) }

    it "doesn't have any permission" do
      expect(subject.permissions[:can]).to be_empty
      expect(subject.permissions[:cannot]).to be_empty
    end
  end

  it { is_expected.to be_able_to(:manage, Decidim::Comments::Comment) }
end
