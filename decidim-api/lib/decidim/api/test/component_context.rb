# frozen_string_literal: true

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
          url
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
  let(:space_type) { "participatoryProcess" }

  shared_examples "graphQL visible resource" do
    it "is visible" do
      expect(response[space_type]["components"].first[lookout_key]).to eq(query_result)
    end
  end

  shared_examples "graphQL hidden space" do
    it "should not be visible" do
      expect(response[space_type]).to be_nil
    end
  end

  shared_examples "graphQL hidden component" do
    it "should not be visible" do
      expect(response[space_type]["components"].first).to be_nil
    end
  end

  shared_examples "graphQL resource visible for admin" do
    context "when the user is admin" do
      let!(:current_user) { create(:user, :admin, :confirmed, organization: current_organization) }

      it_behaves_like "graphQL visible resource"
    end
  end

  shared_examples "graphQL space hidden to visitor" do
    context "when user is visitor" do
      let!(:current_user) { nil }
      it_behaves_like "graphQL hidden space"
    end
  end

  context "when space is published" do
    let!(:participatory_process) { create(process_space_factory, :published, :with_steps, organization: current_organization) }

    context "when component is published" do
      let!(:current_component) { create(component_factory, :published, participatory_space: participatory_process) }

      it_behaves_like "graphQL resource visible for admin"

      context "when the user is space admin" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "admin") }
        it_behaves_like "graphQL visible resource"
      end

      context "when the user is space collaborator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "collaborator") }
        it_behaves_like "graphQL visible resource"
      end

      context "when the user is space moderator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "moderator") }
        it_behaves_like "graphQL visible resource"
      end

      context "when the user is space evaluator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "evaluator") }
        it_behaves_like "graphQL visible resource"
      end

      context "when user is visitor" do
        let!(:current_user) { nil }
        it_behaves_like "graphQL visible resource"
      end

      context "when user is member" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: current_user, privatable_to: participatory_process) }
        it_behaves_like "graphQL visible resource"
      end

      context "when user is member" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: current_user, privatable_to: participatory_process) }
        it_behaves_like "graphQL visible resource"
      end

      context "when user is normal user" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        it_behaves_like "graphQL visible resource"
      end
    end

    context "when component is not published" do
      let!(:current_component) { create(component_factory, :unpublished, participatory_space: participatory_process) }

      it_behaves_like "graphQL resource visible for admin"

      context "when the user is space admin" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "admin") }
        it_behaves_like "graphQL visible resource"
      end

      context "when the user is space collaborator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "collaborator") }
        it_behaves_like "graphQL hidden component"
      end

      context "when the user is space moderator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "moderator") }
        it_behaves_like "graphQL hidden component"
      end

      context "when the user is space evaluator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "evaluator") }
        it_behaves_like "graphQL visible resource"
      end

      context "when user is visitor" do
        let!(:current_user) { nil }

        it_behaves_like "graphQL hidden component"
      end

      context "when user is normal user" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        it_behaves_like "graphQL hidden component"
      end

      context "when user is member" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: current_user, privatable_to: participatory_process) }
        it_behaves_like "graphQL hidden component"
      end
    end
  end

  context "when space is published, private and transparent" do
    let(:process_space_factory) { :assembly }
    let(:space_type) { "assembly" }

    let(:participatory_process_query) do
      %(
      assembly(id: #{participatory_process.id}) {
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
    let!(:participatory_process) { create(process_space_factory, :published, :private, :transparent, organization: current_organization) }

    context "when component is published" do
      let!(:current_component) { create(component_factory, :published, participatory_space: participatory_process) }

      it_behaves_like "graphQL resource visible for admin"

      context "when the user is space admin" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:assembly_user_role, assembly: participatory_process, user: current_user, role: "admin") }
        it_behaves_like "graphQL visible resource"
      end

      context "when the user is space collaborator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:assembly_user_role, assembly: participatory_process, user: current_user, role: "collaborator") }
        it_behaves_like "graphQL visible resource"
      end

      context "when the user is space moderator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:assembly_user_role, assembly: participatory_process, user: current_user, role: "moderator") }
        it_behaves_like "graphQL visible resource"
      end

      context "when the user is space evaluator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:assembly_user_role, assembly: participatory_process, user: current_user, role: "evaluator") }
        it_behaves_like "graphQL visible resource"
      end

      context "when user is visitor" do
        let!(:current_user) { nil }
        it_behaves_like "graphQL visible resource"
      end

      context "when user is member" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:participatory_space_private_user) { create(:assembly_private_user, user: current_user, privatable_to: participatory_process) }
        it_behaves_like "graphQL visible resource"
      end

      context "when user is normal user" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        it_behaves_like "graphQL visible resource"
      end
    end

    context "when component is not published" do
      let!(:current_component) { create(component_factory, :unpublished, participatory_space: participatory_process) }

      it_behaves_like "graphQL resource visible for admin"

      context "when the user is space admin" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:assembly_user_role, assembly: participatory_process, user: current_user, role: "admin") }
        it_behaves_like "graphQL visible resource"
      end

      context "when the user is space collaborator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:assembly_user_role, assembly: participatory_process, user: current_user, role: "collaborator") }
        it_behaves_like "graphQL visible resource"
      end

      context "when the user is space moderator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:assembly_user_role, assembly: participatory_process, user: current_user, role: "moderator") }
        it_behaves_like "graphQL hidden component"
      end

      context "when the user is space evaluator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:assembly_user_role, assembly: participatory_process, user: current_user, role: "evaluator") }
        it_behaves_like "graphQL visible resource"
      end

      context "when user is visitor" do
        let!(:current_user) { nil }
        it_behaves_like "graphQL hidden component"
      end

      context "when user is normal user" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        it_behaves_like "graphQL hidden component"
      end

      context "when user is member" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:participatory_space_private_user) { create(:assembly_private_user, user: current_user, privatable_to: participatory_process) }
        it_behaves_like "graphQL hidden component"
      end
    end
  end

  context "when space is published but private" do
    let!(:participatory_process) { create(process_space_factory, :published, :private, :with_steps, organization: current_organization) }

    context "when component is published" do
      let!(:current_component) { create(component_factory, :published, participatory_space: participatory_process) }

      it_behaves_like "graphQL resource visible for admin"

      context "when the user is space admin" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "admin") }
        it_behaves_like "graphQL hidden space"
      end

      context "when the user is space collaborator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "collaborator") }
        it_behaves_like "graphQL hidden space"
      end

      context "when the user is space moderator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "moderator") }

        it_behaves_like "graphQL hidden space"
      end

      context "when the user is space evaluator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "evaluator") }
        it_behaves_like "graphQL hidden space"
      end

      it_behaves_like "graphQL space hidden to visitor"

      context "when user is normal user" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        it_behaves_like "graphQL hidden space"
      end

      context "when user is member" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: current_user, privatable_to: participatory_process) }
        it_behaves_like "graphQL visible resource"
      end
    end

    context "when component is not published" do
      let!(:current_component) { create(component_factory, :unpublished, participatory_space: participatory_process) }

      it_behaves_like "graphQL resource visible for admin"

      context "when the user is space admin" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "admin") }
        it_behaves_like "graphQL hidden space"
      end

      context "when the user is space collaborator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "collaborator") }
        it_behaves_like "graphQL hidden space"
      end

      context "when the user is space moderator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "moderator") }
        it_behaves_like "graphQL hidden space"
      end

      context "when the user is space evaluator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "evaluator") }
        it_behaves_like "graphQL hidden space"
      end
      it_behaves_like "graphQL space hidden to visitor"

      context "when user is member" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: current_user, privatable_to: participatory_process) }
        it_behaves_like "graphQL hidden component"
      end
      context "when user is normal user" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        it_behaves_like "graphQL hidden space"
      end
    end
  end

  context "when space is unpublished" do
    let(:participatory_process) { create(process_space_factory, :unpublished, :with_steps, organization: current_organization) }

    context "when component is published" do
      let!(:current_component) { create(component_factory, :published, participatory_space: participatory_process) }

      it_behaves_like "graphQL resource visible for admin"

      context "when the user is space admin" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "admin") }
        it_behaves_like "graphQL hidden space"
      end

      context "when the user is space collaborator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "collaborator") }
        it_behaves_like "graphQL hidden space"
      end

      context "when the user is space moderator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "moderator") }
        it_behaves_like "graphQL hidden space"
      end

      context "when the user is space evaluator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "evaluator") }
        it_behaves_like "graphQL hidden space"
      end

      it_behaves_like "graphQL space hidden to visitor"

      context "when user is member" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: current_user, privatable_to: participatory_process) }
        it_behaves_like "graphQL hidden space"
      end

      context "when user is normal user" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        it_behaves_like "graphQL hidden space"
      end
    end

    context "when component is not published" do
      let!(:current_component) { create(component_factory, :unpublished, participatory_space: participatory_process) }

      it_behaves_like "graphQL resource visible for admin"

      context "when the user is space admin" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "admin") }
        it_behaves_like "graphQL hidden space"
      end

      context "when the user is space collaborator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "collaborator") }
        it_behaves_like "graphQL hidden space"
      end

      context "when the user is space moderator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "moderator") }
        it_behaves_like "graphQL hidden space"
      end

      context "when the user is space evaluator" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:role) { create(:participatory_process_user_role, participatory_process:, user: current_user, role: "evaluator") }
        it_behaves_like "graphQL hidden space"
      end
      it_behaves_like "graphQL space hidden to visitor"

      context "when user is member" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }
        let!(:participatory_space_private_user) { create(:participatory_space_private_user, user: current_user, privatable_to: participatory_process) }
        it_behaves_like "graphQL hidden space"
      end

      context "when user is normal user" do
        let!(:current_user) { create(:user, :confirmed, organization: current_organization) }

        it_behaves_like "graphQL hidden space"
      end
    end
  end
end
