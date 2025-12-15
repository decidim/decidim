# frozen_string_literal: true

require "spec_helper"

shared_examples_for "has members" do
  let(:factory_name) { described_class.name.demodulize.underscore.to_sym }

  let!(:public_space) do
    create(factory_name, private_space: false, published_at: Time.current)
  end

  let!(:private_space) do
    create(factory_name, private_space: true, published_at: Time.current)
  end

  def create_space_member(space, user = create(:user, organization: space.organization))
    Decidim::ParticipatorySpace::Member.create(privatable_to: space, user:)
  end

  describe ".public_spaces" do
    let(:scope) { described_class.send(:public_spaces) }

    it { expect(scope).to eq([public_space]) }
  end

  describe ".visible_for" do
    let(:scope) { described_class.send(:visible_for, user) }

    before { create_space_member(private_space) }

    context "without user" do
      let(:user) { nil }

      it { expect(scope).to contain_exactly(public_space) }
    end

    context "with non-member" do
      let(:user) { create(:user) }

      it { expect(scope).to contain_exactly(public_space) }
    end

    context "with member" do
      let(:user) { private_space.users.first }

      it { expect(scope).to contain_exactly(public_space, private_space) }
    end

    context "when the space is both public and has members" do
      # Visible spaces for non-member.
      let(:user) { create(:user) }

      before do
        # Public space has multiple members.
        create_space_member(public_space)
        create_space_member(public_space)
      end

      # Expect no duplicate results.
      it { expect(scope).to contain_exactly(public_space) }
    end
  end
end
