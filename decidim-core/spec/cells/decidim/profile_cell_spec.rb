# frozen_string_literal: true

require "spec_helper"

describe Decidim::ProfileCell, type: :cell do
	controller Decidim::ProfilesController

	let(:organization) { create :organization, user_groups_enabled: true }
	let(:current_user) { create :user, :admin, organization: organization }
	let(:user) { create :user, :managed, organization: organization, suspended: false }
	let(:my_cell) { cell("decidim/profile", user, context: { current_user: current_user }) }

	context "when show is rendered" do
		before do
			allow(user).to receive(:suspended?).and_return(false)
		end

		it "does not show the inaccessible profile alert" do
			html = cell("decidim/profile", user, context: { current_user: current_user }).call
			expect(html).not_to have_text("This profile is inaccessible due to Terms and Conditions violation!")
		end

	end

	context "when the user displayed is suspended" do
		before do
			allow(user).to receive(:suspended?).and_return(true)
		end
		it "shows the inaccessible profile alert" do
			html = cell("decidim/profile", user, context: { current_user: current_user }).call
			expect(html).to have_text("This profile is inaccessible due to Terms and Conditions violation!")
		end
	end

	context "when the current user is not admin" do
		before do
			allow(user).to receive(:suspended?).and_return(false)
		end
		it "shows the inaccessible profile alert" do
			html = cell("decidim/profile", user, context: { current_user: current_user }).call
			expect(html).to have_text("This profile is inaccessible due to Terms and Conditions violation!")
		end
	end
end
