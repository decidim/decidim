# frozen_string_literal: true

module Decidim
  # This cell renders tabs and panels based on an items array wich contains
  # hashes with items required to render them. Each item represent a panel
  # and a tab and has the following keys:
  #
  # - enabled: Whether the tab has to be displayed
  # - id: Suffix used to generate the id of each tab and panel
  # - text: Text of the panel
  # - icon: Icon key of the panel
  # - method: The method to render the panel content (for example, :cell or
  #           :render)
  # - args: The arguments to be passed to the method to render the panel
  #         content
  #
  # The `model` is expected to be a resource with HasAttachments concern
  #
  class TabPanelsCell < Decidim::ViewModel
    include IconHelper

    def show
      return if model.blank?

      render :show
    end

    def items
      @items ||= model.select { |item| item[:enabled] }
    end

    def tabs
      @tabs ||= items.map { |item| item.slice(:id, :text, :icon) }
    end

    def panels
      @panels ||= items.map { |item| item.slice(:id, :method, :args) }
    end
  end
end
