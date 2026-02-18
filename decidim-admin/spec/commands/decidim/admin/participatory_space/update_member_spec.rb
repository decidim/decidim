# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin::ParticipatorySpace
  describe UpdateMember do
    subject { described_class.new(form, member) }

    let!(:participatory_space) { create(:participatory_process) }
    let!(:member) { create(:member, :unpublished, user:, role:) }
    let!(:user) { create(:user, email: "my_email@example.org", organization: participatory_space.organization) }
    let!(:current_user) { create(:user, email: "some_email@example.org", organization: participatory_space.organization) }

    let(:form) do
      double(
        invalid?: invalid,
        current_user:,
        role:,
        published:
      )
    end
    let(:invalid) { false }
    let(:role) { generate_localized_title(:role) }
    let(:published) { true }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "updates the role" do
        subject.call

        expect(translated(member.reload.role)).to eq(translated_attribute(role))
      end

      it "updates the published status" do
        subject.call

        expect(member.reload.published).to eq(published)
      end
    end
  end
end
