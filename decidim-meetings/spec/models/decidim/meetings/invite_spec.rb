# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe Invite do
      subject { invite }

      let(:invite) { build_stubbed(:invite) }

      it { is_expected.to be_valid }

      it "has an associated meeting" do
        expect(invite.meeting).to be_a(Decidim::Meetings::Meeting)
      end

      it "has an associated user" do
        expect(invite.user).to be_a(Decidim::User)
      end

      context "without a meeting" do
        let(:invite) { build :invite, meeting: nil }

        it { is_expected.not_to be_valid }
      end

      context "without an user" do
        let(:invite) { build :invite, user: nil }

        it { is_expected.not_to be_valid }
      end

      describe "#accept!" do
        let(:invite) { create(:invite, accepted_at: nil, rejected_at: Time.current) }

        it "sets the accepted_at attribute" do
          expect { subject.accept! }.to change(subject, :accepted_at).from(nil).to(kind_of(Time))
        end

        it "sets the rejected_at attribute" do
          expect { subject.accept! }.to change(subject, :rejected_at).from(kind_of(Time)).to(nil)
        end
      end

      shared_examples "rejecting and invitation" do |method_name|
        let(:invite) { create(:invite, accepted_at: Time.current, rejected_at: nil) }

        it "sets the accepted_at attribute" do
          expect { subject.send(method_name) }.to change(subject, :accepted_at).from(kind_of(Time)).to(nil)
        end

        it "sets the rejected_at attribute" do
          expect { subject.send(method_name) }.to change(subject, :rejected_at).from(nil).to(kind_of(Time))
        end
      end

      describe "#reject!" do
        it_behaves_like "rejecting and invitation", :reject!
      end

      describe "#decline!" do
        it_behaves_like "rejecting and invitation", :decline!
      end
    end
  end
end
