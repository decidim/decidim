# frozen_string_literal: true

require "spec_helper"

describe Decidim::Verifications::Authorizations do
  let(:name) { "some_method" }
  let(:user) { create(:user) }

  let!(:granted_for_user_and_method) do
    create(:authorization, :granted, name: name, user: user)
  end

  let!(:pending_for_other_user) do
    create(:authorization, :pending, name: name)
  end

  let!(:granted_for_other_user) do
    create(:authorization, :granted, name: name)
  end

  let!(:pending_for_other_method) do
    create(:authorization, :pending, user: user)
  end

  let!(:granted_for_other_method) do
    create(:authorization, :granted, user: user)
  end

  let!(:pending_for_other_user_and_method) do
    create(:authorization, :pending)
  end

  let!(:granted_for_other_user_and_method) do
    create(:authorization, :granted)
  end

  shared_examples_for "a correct usage of the query" do
    subject { described_class.new(parameters).query.to_a }

    it { is_expected.to match_array(expectation) }
  end

  describe "no filtering" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { user: nil, name: nil, granted: nil }
      end

      let(:expectation) do
        [
          granted_for_user_and_method,
          granted_for_other_user,
          pending_for_other_user,
          granted_for_other_method,
          pending_for_other_method,
          granted_for_other_user_and_method,
          pending_for_other_user_and_method
        ]
      end
    end
  end

  describe "granted only" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { user: nil, name: nil, granted: true }
      end

      let(:expectation) do
        [
          granted_for_user_and_method,
          granted_for_other_user,
          granted_for_other_method,
          granted_for_other_user_and_method
        ]
      end
    end
  end

  describe "pending only" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { user: nil, name: nil, granted: false }
      end

      let(:expectation) do
        [
          pending_for_other_user,
          pending_for_other_method,
          pending_for_other_user_and_method
        ]
      end
    end
  end

  describe "by method" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { user: nil, name: name, granted: nil }
      end

      let(:expectation) do
        [
          granted_for_user_and_method,
          granted_for_other_user,
          pending_for_other_user
        ]
      end
    end
  end

  describe "granted by method" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { user: nil, name: name, granted: true }
      end

      let(:expectation) do
        [granted_for_user_and_method, granted_for_other_user]
      end
    end
  end

  describe "pending by method" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { user: nil, name: name, granted: false }
      end

      let(:expectation) do
        [pending_for_other_user]
      end
    end
  end

  describe "by user" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { user: user, name: nil, granted: nil }
      end

      let(:expectation) do
        [
          granted_for_user_and_method,
          granted_for_other_method,
          pending_for_other_method
        ]
      end
    end
  end

  describe "granted by user" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { user: user, name: nil, granted: true }
      end

      let(:expectation) do
        [granted_for_user_and_method, granted_for_other_method]
      end
    end
  end

  describe "pending by user" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { user: user, name: nil, granted: false }
      end

      let(:expectation) { [pending_for_other_method] }
    end
  end

  describe "by user and method" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { user: user, name: name, granted: nil }
      end

      let(:expectation) { [granted_for_user_and_method] }
    end
  end

  describe "granted by user and method" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { user: user, name: name, granted: true }
      end

      let(:expectation) { [granted_for_user_and_method] }
    end
  end

  describe "pending by user and method" do
    it_behaves_like "a correct usage of the query" do
      let(:parameters) do
        { user: user, name: name, granted: false }
      end

      let(:expectation) { [] }
    end
  end
end
