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

        it "returns the followers" do
          expect(subject.users_to_notify_on_comment_created).to match_array(follows.map(&:user))
        end
      end
    end
  end
end
