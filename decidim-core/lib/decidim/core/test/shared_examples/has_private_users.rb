# frozen_string_literal: true

require "spec_helper"

shared_examples_for "has private users" do
  let(:factory_name) { described_class.name.demodulize.underscore.to_sym }

  let!(:public_space) do
    create(factory_name, private_space: false, published_at: Time.current)
  end

  let!(:private_space) do
    create(factory_name, private_space: true, published_at: Time.current)
  end

  def create_space_private_user(space, user = create(:user, organization: space.organization))
    Decidim::ParticipatorySpacePrivateUser.create(privatable_to: space, user: user)
  end

  describe ".public_spaces" do
    let(:scope) { described_class.send(:public_spaces) }

    it { expect(scope).to eq([public_space]) }
  end

  describe ".visible_for" do
    let(:scope) { described_class.send(:visible_for, user) }

    before { create_space_private_user(private_space) }

    context "without user" do
      let(:user) { nil }

      it { expect(scope).to contain_exactly(public_space) }
    end

    context "with non-private user" do
      let(:user) { create(:user) }

      it { expect(scope).to contain_exactly(public_space) }
    end

    context "with private user" do
      let(:user) { private_space.users.first }

      it { expect(scope).to contain_exactly(public_space, private_space) }
    end

    context "when the space is both public and has private users" do
      let(:user) { create(:user) } # Non-private user

      before do
        create_space_private_user(public_space) # Multiple users
        create_space_private_user(public_space) # Multiple users
      end

      it { expect(scope).to contain_exactly(public_space) } # Expect no duplicates
    end
  end
end
