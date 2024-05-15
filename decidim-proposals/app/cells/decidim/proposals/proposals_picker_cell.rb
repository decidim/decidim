# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders a proposals picker.
    class ProposalsPickerCell < Decidim::ViewModel
      MAX_PROPOSALS = 1000

      def show
        render
      end

      alias component model

      def form
        options[:form]
      end

      def field
        options[:field]
      end

      def form_name
        "#{form.object_name}[#{method_name}]"
      end

      def method_name
        field.to_s.sub(/s$/, "_ids")
      end

      def selected_ids
        form.object.send(method_name)
      end

      def proposals
        @proposals ||= Decidim.find_resource_manifest(:proposals).try(:resource_scope, component)
                         &.includes(:component)
                         &.published
                         &.not_hidden
                         &.order(id: :asc)
      end

      def decorated_proposals
        proposals.limit(MAX_PROPOSALS).each do |proposal|
          yield Decidim::Proposals::ProposalPresenter.new(proposal)
        end
      end
    end
  end
end
