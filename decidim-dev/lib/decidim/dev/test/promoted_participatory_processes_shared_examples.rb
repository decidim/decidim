# frozen_string_literal: true

shared_examples "with promoted participatory processes and groups" do
  before do
    request.env["decidim.current_organization"] = organization
  end

  describe "promoted_collection" do
    it "includes promoted participatory processes and groups placing groups in first place" do
      create(
        :participatory_process_group,
        organization:
      )

      unpromoted_process = create(
        :participatory_process,
        :with_phases,
        :published,
        organization:
      )
      unpromoted_process.active_phase.update!(end_date: Time.current.advance(days: 1))

      promoted_process = create(
        :participatory_process,
        :with_phases,
        :published,
        :promoted,
        organization:
      )
      promoted_process.active_phase.update!(end_date: Time.current.advance(days: 2))

      promoted_group = create(
        :participatory_process_group,
        :promoted,
        organization:
      )

      _external_promoted_group = create(
        :participatory_process_group,
        :promoted
      )

      expect(controller.helpers.promoted_collection).to(
        match_array([promoted_group, promoted_process])
      )
    end

    it "orders participatory processes by active_phase end_date" do
      create(
        :participatory_process,
        :with_phases,
        :unpublished,
        :promoted,
        organization:
      )

      create(
        :participatory_process,
        :with_phases,
        :unpublished,
        organization:
      )

      last =
        create(
          :participatory_process,
          :with_phases,
          :published,
          :promoted,
          organization:
        )

      last.active_phase.update!(end_date: nil)

      first =
        create(
          :participatory_process,
          :with_phases,
          :published,
          :promoted,
          organization:,
          end_date: Time.current.advance(days: 10)
        )

      first.active_phase.update!(end_date: Time.current.advance(days: 2))

      second =
        create(
          :participatory_process,
          :with_phases,
          :published,
          :promoted,
          organization:,
          end_date: Time.current.advance(days: 8)
        )

      second.active_phase.update!(end_date: Time.current.advance(days: 4))

      expect(controller.helpers.promoted_collection).to(
        match_array([first, second, last])
      )
    end
  end
end
