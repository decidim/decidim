# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UpdateUserInterests do
    let(:command) { described_class.new(user, form) }
    let(:user) { create(:user) }
    let(:interested_scope) { create :scope, organization: user.organization }
    let(:ignored_scope) { create :scope, organization: user.organization }
    let(:ignored_area) { create :area, organization: user.organization }
    let(:data) do
      {
        scopes: {
          ignored_scope.id.to_s => {
            "checked": "0",
            "id": ignored_scope.id.to_s
          },
          interested_scope.id.to_s => {
            "checked": "1",
            "id": interested_scope.id.to_s
          }
        }
      }
    end

    let(:form) do
      Decidim::UserInterestsForm.from_params(user: data)
    end

    context "when invalid" do
      before do
        allow(form).to receive(:valid?).and_return(false)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end
    end

    context "when valid" do
      it "updates the users's interested scopes" do
        expect { command.call }.to broadcast(:ok)
        user.reload
        expect(user.interested_scopes).to eq [interested_scope]
      end

      it "saves interested scopes ids as array of Integer" do
        command.call
        user.reload
        expect(user.extended_data["interested_scopes"]).to eq [interested_scope.id]
      end
    end
  end
end
