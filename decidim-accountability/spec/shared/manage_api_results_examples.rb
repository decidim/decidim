# frozen_string_literal: true

shared_examples "API creatable result" do
  context "when form is ok" do
    it "creates the result" do
      expect do
        execute_query(query, variables)
      end.to change(Decidim::Accountability::Result, :count).by(1)
    end

    it "returns the result" do
      expect(api_response).to be_present
      result = Decidim::Accountability::Result.last
      expect(api_response).to include(
        {
          "description" => { "translation" => description_en },
          "title" => { "translation" => title_en },
          "proposals" => [],
          "projects" => [],
          "externalId" => "dummy_external_id",
          "progress" => 12.4,
          "startDate" => "2020-01-01",
          "taxonomies" => [],
          "weight" => 0,
          "id" => result.id.to_s
        }
      )
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:create!)
        .with(Decidim::Accountability::Result, current_user, kind_of(Hash), visibility: "all")
        .and_call_original

      expect { execute_query(query, variables) }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
    end

    context "with linking resources" do
      include_context "with linking resources"
      let!(:proposal_ids) { [1234, foreign_proposal.id, proposal.id] }
      let!(:project_ids) { [1235, foreign_project.id, project.id] }

      it "links only belonging resources" do
        expect(api_response).to include(
          {
            "proposals" => [
              { "id" => proposal.id.to_s }
            ],
            "projects" => [
              { "id" => project.id.to_s }
            ]
          }
        )
        result = Decidim::Accountability::Result.last
        linked_proposals = result.linked_resources(:proposals, "included_proposals")
        linked_projects = result.linked_resources(:projects, "included_projects")

        expect(linked_proposals).to eq([proposal])
        expect(linked_projects).to eq([project])
      end
    end

    describe "#taxonomy" do
      include_context "with taxonomies"

      context "with invalid taxonomies" do
        let!(:taxonomies) { invalid_taxonomies.map(&:id) }

        it "raised error" do
          expect do
            execute_query(query, variables)
          end.to raise_error(StandardError)
        end
      end

      context "with valid taxonomies" do
        let!(:taxonomies) { valid_taxonomies.map(&:id) }

        it "attached only belonging taxonomies" do
          api_response
          expect(api_response).to include(
            {
              "taxonomies" => [
                { "id" => valid_taxonomies.first.id.to_s },
                { "id" => valid_taxonomies.second.id.to_s }
              ]
            }
          )
        end
      end
    end
  end

  context "when there is an error in the form" do
    let!(:title_en) { nil }

    it "returns the error" do
      expect do
        execute_query(query, variables)
      end.to raise_error(StandardError)
    end
  end
end
