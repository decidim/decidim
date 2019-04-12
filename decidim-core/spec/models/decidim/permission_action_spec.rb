# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe PermissionAction do
    let(:permission_action) do
      PermissionAction.new(scope: :test, action: :check, subject: :result)
    end

    context "when checking for same attributes" do
      it "is the same action" do
        expect(permission_action.for?(:test, :check, :result)).to be true
      end
    end

    context "when checking for different attributes" do
      it "has different scope" do
        expect(permission_action.for?(:testing, :check, :result)).to be false
      end
      it "has different action" do
        expect(permission_action.for?(:test, :match, :result)).to be false
      end
      it "has different subject" do
        expect(permission_action.for?(:test, :check, :asdf)).to be false
      end
    end
  end
end
