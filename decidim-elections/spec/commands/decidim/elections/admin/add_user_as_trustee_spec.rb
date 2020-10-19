# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::AddUserAsTrustee do
  subject { described_class.new(form, current_user) }

  let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "elections" }
  let(:current_user) { create :user, :admin, :confirmed, organization: organization }
  let(:user) { create :user, :confirmed }
  let(:form) do
    double(
      invalid?: invalid,
      user: user,
      current_user: current_user,
      current_participatory_space: current_component.participatory_space
    )
  end
  let(:invalid) { false }

  let(:trustee) { Decidim::Elections::Trustee.last }

  it "add the user to trustees" do
    expect { subject.call }.to change { Decidim::Elections::Trustee.count }.by(1)
  end

  it "adds a participatory space to trustee" do
    subject.call
    expect(trustee.trustees_participatory_spaces.count).to eq 1
  end

  context "when user and participatory space exist" do
    let!(:trustee) do
      trustee = create(:trustee,
                       decidim_user_id: user.id)
      trustee.trustees_participatory_spaces.create(
        participatory_space: form.current_participatory_space
      )
    end

    it "broadcasts exists" do
      expect { subject.call }.to broadcast(:exists)
    end
  end
end
