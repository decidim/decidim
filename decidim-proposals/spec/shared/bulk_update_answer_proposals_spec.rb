# frozen_string_literal: true

shared_examples "bulk update answer proposals" do
  let!(:evaluating_state) { create(:proposal_state, :evaluating, component: proposal_component) }
  let!(:accepted_state) { create(:proposal_state, :accepted, component: proposal_component, token: :accepted) }
  let!(:amendable) { create(:proposal, component: proposal_component) }
  let!(:emendation) { create(:proposal, component: proposal_component) }
  let!(:amendment) { create(:amendment, amendable: amendable, emendation: emendation, amender: emendation.creator_author) }
  let!(:proposal_without_permission) { emendation }
  let!(:proposals_with_permission) { create_list(:proposal, 2, component: proposal_component) }
  let!(:template) { create(:template, target: :proposal_answer, templatable: proposal_component, field_values: { "proposal_state_id" => evaluating_state.id }) }
  let!(:answer_with_cost_template) { create(:template, target: :proposal_answer, templatable: proposal_component, field_values: { "proposal_state_id" => accepted_state.id }) }

  let(:cleaned_params) do
    answer_form_params.transform_values do |value|
      value.is_a?(String) ? value.gsub(%r{<script.*?>.*?</script>}, "").strip : value
    end
  end

  context "when selecting proposals" do
    let!(:proposal_component) { current_component }

    context "when clicking the bulk action button" do
      before do
        visit current_path
        page.find(".js-check-all").set(true)
        click_on "Actions"
      end

      it "shows the change action option if proposals have permission" do
        expect(page).to have_button("Change status and answer")
      end

      it "does not show the change action option if proposals do not have permission" do
        page.find(".js-check-all").set(false)
        page.find(".js-proposal-id-#{proposal_without_permission.id}").set(true)
        click_on "Actions"
        expect(page).to have_no_button("Change status and answer")
      end
    end

    context "when change status and answer is selected from the actions dropdown" do
      before do
        visit current_path
        page.find(".js-check-all").set(false)
        proposals_with_permission.each do |proposal|
          page.find(".js-proposal-id-#{proposal.id}").set(true)
        end
        click_on "Actions"
        click_on "Change status and answer"
      end

      it "shows the template select" do
        expect(page).to have_css("#template_template_id", count: 1)
      end

      it "shows an update button" do
        expect(page).to have_button(id: "js-submit-change-answer-status", text: "Update", count: 1)
      end

      context "when submitting the form" do
        before do
          within "#js-form-change-answer-status" do
            select translated(answer_with_cost_template.name), from: :template_template_id
            perform_enqueued_jobs do
              click_on "Update"
            end
          end
        end

        it "changes the status and answer of the selected proposals" do
          expect(page).to have_content("The proposals have been queued for answer update.")

          proposals_with_permission.each do |proposal|
            expect(page).to have_css("tr[data-id='#{proposal.id}']", text: translated(accepted_state.title))
          end
        end
      end
    end

    context "when cost is required" do
      let!(:proposal_component) do
        create(:proposal_component, :with_costs_enabled, :published, participatory_space: current_component.participatory_space, name: "New component")
      end
      let!(:proposal_with_cost) { create(:proposal, :not_answered, component: proposal_component, cost: 10) }
      let!(:proposal_without_cost) do
        create(:proposal, :not_answered, title: "Proposal without cost", component: proposal_component, cost: nil)
      end

      before do
        visit manage_component_path(proposal_component)
      end

      context "when cost is provided" do
        before do
          visit current_path
          page.find(".js-check-all").set(false)
          page.find(".js-proposal-id-#{proposal_with_cost.id}").set(true)

          click_on "Actions"
          click_on "Change status and answer"

          within "#js-form-change-answer-status" do
            select translated(answer_with_cost_template.name), from: :template_template_id
            perform_enqueued_jobs do
              click_on "Update"
            end
            sleep 1
          end
        end

        it "changes the status and answer of the selected proposals" do
          expect(page).to have_content("The proposals have been queued for answer update.")

          expect(page).to have_css("tr[data-id='#{proposal_with_cost.id}']", text: translated(accepted_state.title))
        end
      end

      context "when cost is not provided" do

        before do
          allow_any_instance_of(Decidim::Proposals::Proposal).to receive(:internal_state).and_return("accepted")
          page.find_by_id("proposals_bulk", class: "js-check-all").set(false)
          page.find(".js-proposal-id-#{proposal_without_cost.id}").set(true)
          click_on "Actions"
          click_on "Change status and answer"
          within "#js-form-change-answer-status" do
            select translated(answer_with_cost_template.name), from: :template_template_id
            perform_enqueued_jobs { click_on "Update" }
          end
        end

        it "shows a missing cost data alert" do
          puts "Proposal without cost: #{proposal_without_cost.id}"
          puts "cost: #{proposal_without_cost.cost}"
          puts "cost_enabled: #{proposal_component.current_settings.answers_with_costs?}"
          expect(page).to have_content("Please fill in the required cost field for all selected proposals.")
        end
      end
    end
  end
end
