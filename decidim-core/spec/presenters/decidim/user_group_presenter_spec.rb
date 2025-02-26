# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserGroupPresenter, type: :helper do
    let(:presenter) { described_class.new(group) }
    let(:group) { build(:user_group) }

    describe "#can_be_contacted?" do
      subject { presenter.can_be_contacted? }

      it { is_expected.to be(true) }
    end

    describe "#officialization_text" do
      subject { presenter.officialization_text }

      it { is_expected.to eq("This group is publicly verified, its name has been verified to correspond with its real name.") }
    end
  end
end
