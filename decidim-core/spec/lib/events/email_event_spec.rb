# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Events::EmailEvent do
    # rubocop:disable RSpec/LeakyConstantDeclaration
    class TestEvent < Decidim::Events::BaseEvent
      include Events::EmailEvent
    end
    # rubocop:enable RSpec/LeakyConstantDeclaration

    describe ".types" do
      subject { TestEvent }

      it "adds `:email` to the types array" do
        expect(subject.types).to include :email
      end
    end
  end
end
