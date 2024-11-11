# frozen_string_literal: true

require "decidim/api/test/type_context"

shared_context "with a graphql decidim component" do
  include_context "with a graphql class type"

  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }

  let(:participatory_process) { create(:participatory_process, organization: current_organization) }
  let(:taxonomy) { create(:taxonomy, :with_parent, organization: participatory_process.organization) }
  let(:taxonomies) { [taxonomy] }

  let(:component_type) { nil }
  let(:component_fragment) { nil }

  let(:participatory_process_query) do
    %(
      participatoryProcess(id: #{participatory_process.id}) {
        components(filter: {type: "#{component_type}"}){
          id
          name {
            translation(locale: "#{locale}")
          }
          weight
          __typename
          ...fooComponent
        }
        id
      }
    )
  end

  let(:query) do
    %(
      query {
        #{participatory_process_query}
      }
      #{component_fragment}
    )
  end
end

shared_examples "with resource visibility" do
  let(:process_space_factory) { :participatory_process }

  context "when space is published" do
    let!(:participatory_process) { create(process_space_factory, :published, :with_steps, organization: current_organization) }

    context "when component is published" do
      let!(:current_component) { create(component_factory, :published, participatory_space: participatory_process) }

      context "when the user is admin" do
        let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

        it "should be visible" do
          expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
        end
      end

      Decidim::ParticipatorySpaceUser::ROLES.each do |role|
        context "when the user is space #{role}" do
          let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

          it "should be visible" do
            expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
          end
        end
      end

      context "when user is visitor" do
        let!(:current_user) { nil }

        it "should be visible" do
          expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
        end
      end

      context "when user is member" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: current_user, privatable_to: participatory_process) }

        it "should be visible" do
          expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
        end
      end

      context "when user is member" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: current_user, privatable_to: participatory_process) }

        it "should be visible" do
          expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
        end
      end

      context "when user is normal user" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

        it "should be visible" do
          expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
        end
      end
    end

    context "when component is not published" do
      let!(:current_component) { create(component_factory, :unpublished, participatory_space: participatory_process) }

      context "when the user is admin" do
        let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

        it "should be visible" do
          expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
        end
      end

      Decidim::ParticipatorySpaceUser::ROLES.each do |role|
        context "when the user is space #{role}" do
          let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

          it "should be visible" do
            expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
          end
        end
      end

      context "when user is visitor" do
        let!(:current_user) { nil }

        it "should not be visible" do
          expect(response["participatoryProcess"]["components"].first).to be_nil
        end
      end

      context "when user is normal user" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

        it "should not be visible" do
          expect(response["participatoryProcess"]["components"].first).to be_nil
        end
      end

      context "when user is member" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: current_user, privatable_to: participatory_process) }

        it "should be visible" do
          expect(response["participatoryProcess"]["components"].first).to be_nil
        end
      end
    end
  end

  context "when space is published but private" do
    let!(:participatory_process) { create(process_space_factory, :published, :private, :with_steps, organization: current_organization) }

    context "when component is published" do
      let!(:current_component) { create(component_factory, :published, participatory_space: participatory_process) }

      context "when the user is admin" do
        let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

        it "should be visible" do
          expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
        end
      end

      Decidim::ParticipatorySpaceUser::ROLES.each do |role|
        context "when the user is space #{role}" do
          let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

          it "should be visible" do
            expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
          end
        end
      end

      context "when user is visitor" do
        let!(:current_user) { nil }

        it "should not be visible" do
          expect(response["participatoryProcess"]).to be_nil
        end
      end

      context "when user is member" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: current_user, privatable_to: participatory_process) }

        it "should be visible" do
          expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
        end
      end

      context "when user is normal user" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

        it "should not be visible" do
          expect(response["participatoryProcess"]).to be_nil
        end
      end
    end

    context "when component is not published" do
      let!(:current_component) { create(component_factory, :unpublished, participatory_space: participatory_process) }

      context "when the user is admin" do
        let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

        it "should be visible" do
          expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
        end
      end

      Decidim::ParticipatorySpaceUser::ROLES.each do |role|
        context "when the user is space #{role}" do
          let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

          it "should be visible" do
            expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
          end
        end
      end

      context "when user is visitor" do
        let!(:current_user) { nil }

        it "should not be visible" do
          expect(response["participatoryProcess"]).to be_nil
        end

        context "when user is member" do
          let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
          let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: current_user, privatable_to: participatory_process) }

          it "should be visible" do
            expect(response["participatoryProcess"]["components"].first).to be_nil
          end
        end
      end

      context "when user is normal user" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

        it "should not be visible" do
          expect(response["participatoryProcess"]).to be_nil
        end
      end
    end
  end

  context "when space is unpublished" do
    let(:participatory_process) { create(process_space_factory, :unpublished, :with_steps, organization: current_organization) }

    context "when component is published" do
      let!(:current_component) { create(component_factory, :published, participatory_space: participatory_process) }

      context "when the user is admin" do
        let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

        it "should be visible" do
          expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
        end
      end

      Decidim::ParticipatorySpaceUser::ROLES.each do |role|
        context "when the user is space #{role}" do
          let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

          it "should be visible" do
            expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
          end
        end
      end

      context "when user is visitor" do
        let!(:current_user) { nil }

        it "should not be visible" do
          expect(response["participatoryProcess"]).to be_nil
        end
      end

      context "when user is member" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: current_user, privatable_to: participatory_process) }

        it "should be visible" do
          expect(response["participatoryProcess"]).to be_nil
        end
      end

      context "when user is normal user" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

        it "should not be visible" do
          expect(response["participatoryProcess"]).to be_nil
        end
      end
    end

    context "when component is not published" do
      let!(:current_component) { create(component_factory, :unpublished, participatory_space: participatory_process) }

      context "when the user is admin" do
        let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

        it "should be visible" do
          expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
        end
      end

      Decidim::ParticipatorySpaceUser::ROLES.each do |role|
        context "when the user is space #{role}" do
          let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

          it "should be visible" do
            expect(response["participatoryProcess"]["components"].first[lookout_key]).to eq(query_result)
          end
        end
      end

      context "when user is visitor" do
        let!(:current_user) { nil }

        it "should not be visible" do
          expect(response["participatoryProcess"]).to be_nil
        end
      end

      context "when user is member" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: current_user, privatable_to: participatory_process) }

        it "should be visible" do
          expect(response["participatoryProcess"]).to be_nil
        end
      end

      context "when user is normal user" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

        it "should not be visible" do
          expect(response["participatoryProcess"]).to be_nil
        end
      end
    end
  end
end
