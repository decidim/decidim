# frozen_string_literal: true

require "spec_helper"

describe Decidim::Authorizations do
  let(:name) { "some_method" }
  let(:user) { create(:user) }

  let!(:for_user_and_method) do
    create(:authorization, name: name, user: user)
  end

  let!(:for_other_user) do
    create(:authorization, name: name)
  end

  let!(:for_other_method) do
    create(:authorization, user: user)
  end

  let!(:for_other_user_and_method) do
    create(:authorization)
  end

  shared_examples_for "a correct usage of the query" do
    subject { described_class.new(parameters).query.to_a }

    it { is_expected.to match_array(expectation) }
  end

  describe "no filtering" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { user: nil, name: nil }
      end

      let(:expectation) do
        [
          for_user_and_method,
          for_other_user,
          for_other_method,
          for_other_user_and_method
        ]
      end
    end
  end

  describe "by method" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { user: nil, name: name }
      end

      let(:expectation) do
        [for_user_and_method, for_other_user]
      end
    end
  end

  describe "by user and method" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { user: user, name: name }
      end

      let(:expectation) { [for_user_and_method] }
    end
  end
end
