# frozen_string_literal: true

shared_examples "profile visibility" do
  shared_examples "basic profile visibility" do
    context "when managed" do
      before { profile.update!(managed: true) }

      it { is_expected.to be(false) }
    end

    context "when deleted" do
      before { profile.update!(deleted_at: Time.zone.now) }

      it { is_expected.to be(false) }
    end

    context "when confirmed" do
      before { profile.update!(confirmed_at: Time.zone.now) }

      it { is_expected.to be(true) }
    end

    context "when unconfirmed" do
      before { profile.update!(confirmed_at: nil) }

      it { is_expected.to be(false) }
    end
  end

  describe "#profile_published?" do
    subject { profile.profile_published? }

    include_examples "basic profile visibility"
  end

  describe "#visible?" do
    subject { profile.visible? }

    include_examples "basic profile visibility"

    context "when blocked" do
      before { profile.update!(blocked: true) }

      it { is_expected.to be(false) }
    end
  end
end
