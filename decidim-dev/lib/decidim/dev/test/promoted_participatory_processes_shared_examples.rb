# frozen_string_literal: true

shared_examples "with promoted participatory processes" do
  before do
    request.env["decidim.current_organization"] = organization
  end

  describe "promoted_participatory_processes" do
    it "orders them by active_step end_date" do
      create(
        :participatory_process,
        :with_steps,
        :unpublished,
        :promoted,
        organization: organization
      )

      create(
        :participatory_process,
        :with_steps,
        :unpublished,
        organization: organization
      )

      last =
        create(
          :participatory_process,
          :with_steps,
          :published,
          :promoted,
          organization: organization
        )

      last.active_step.update!(end_date: nil)

      first =
        create(
          :participatory_process,
          :with_steps,
          :published,
          :promoted,
          organization: organization,
          end_date: Time.current.advance(days: 10)
        )

      first.active_step.update!(end_date: Time.current.advance(days: 2))

      second =
        create(
          :participatory_process,
          :with_steps,
          :published,
          :promoted,
          organization: organization,
          end_date: Time.current.advance(days: 8)
        )

      second.active_step.update!(end_date: Time.current.advance(days: 4))

      expect(controller.helpers.promoted_participatory_processes).to(
        match_array([first, second, last])
      )
    end
  end
end
