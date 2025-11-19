# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MenuHelper do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization: organization) }
    let!(:process) { create(:participatory_process, :active, weight: 1, organization:) }
    let!(:process_two) { create(:participatory_process, :active, weight: 2, organization:) }
    let!(:process_three) { create(:participatory_process, :active, :promoted, weight: 3, organization:) }

    before do
      allow(helper).to receive(:current_organization).and_return(organization)
      allow(helper).to receive(:current_user).and_return(user)
    end

    describe "#menu_highlighted_participatory_process" do
      context "when all processes are unpublished" do
        before do
          process.update!(published_at: nil)
          process_two.update!(published_at: nil)
          process_three.update!(published_at: nil)
        end

        it "returns nil" do
          expect(helper.menu_highlighted_participatory_process).to be_nil
        end
      end

      context "when all processes are published" do
        it "returns the published promoted process" do
          expect(helper.menu_highlighted_participatory_process).to eq(process_three)
        end
      end

      context "when promoted process is unpublished" do
        before do
          process_three.update!(published_at: nil)
        end

        it "returns nil" do
          expect(helper.menu_highlighted_participatory_process).to be_nil
        end
      end

      context "when there are 2 promoted published processes" do
        before do
          process_two.update!(promoted: true)
        end

        it "returns the published promoted process with minimum weight" do
          expect(helper.menu_highlighted_participatory_process).to eq(process_two)
        end
      end

      context "when there are 2 promoted processes" do
        context "and the one with minimum weight is not published" do
          before do
            process_two.update!(promoted: true, published_at: nil)
          end

          it "returns the other published promoted process" do
            expect(helper.menu_highlighted_participatory_process).to eq(process_three)
          end
        end

        context "and the promoted published process with minimum weight is private" do
          before do
            process_two.update!(promoted: true, private_space: true)
          end

          context "and current_user is private user of that process" do
            let!(:participatory_space_private_user) { create(:participatory_space_private_user, privatable_to: process_two, user:) }

            it "returns the private process" do
              expect(helper.menu_highlighted_participatory_process).to eq(process_two)
            end
          end

          context "and current_user is not private user of that process" do
            it "returns the other published promoted process" do
              expect(helper.menu_highlighted_participatory_process).to eq(process_three)
            end
          end
        end
      end
    end
  end
end
