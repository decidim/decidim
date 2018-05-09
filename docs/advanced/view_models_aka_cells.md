# View Models (a.k.a. Cells)

## General description

A cell is an object that represent a fragment of your UI. The scope of that fragment can embrace an entire page, a single comment container in a thread or just an avatar image link.

Cells are faster than ActionView. While exposing a better performance, you step-wise encapsulate fragments into cell widgets and enforce interfaces.

### View Model

Think of cells, or view models, as small Rails controllers, but without any HTTP coupling. Cells embrace all presentation and rendering logic to present a fragment of the UI.

## Decidim Cards

`card_for @instance` will render the corresponding default card for each component instance.
If a `component.card` is not registered a _basic_ (deafult) card is shown.

To render a specified size/variation include the `size` option as a `symbol`: `card_for @instance, size: :m`

## Introducing a Card Cell to a `component`

- add **dependency** to "decidim-*.gemspec"

  ```rb
  s.add_dependency "cells-erb", "~> 0.1.0"
  s.add_dependency "cells-rails", "~> 0.0.9"
  ```

- **autoload** view_model to module `decidim-<module>/lib/decidim/<module>.rb`

  ```rb
  autoload :ViewModel, "decidim/<module>/view_model"
  ```

- **require** cells in `decidim-<module>/lib/decidim/<module>/engine.rb`

  ```rb
  require "cells/rails"
  require "cells-erb"

  initializer "decidim_<module>.add_cells_view_paths" do
    Cell::ViewModel.view_paths << File.expand_path("#{Decidim::<Module>::Engine.root}/app/cells")
    Cell::ViewModel.view_paths << File.expand_path("#{Decidim::<Module>::Engine.root}/app/views") # for partials
  end
  ```

- The attribute `card` of the Components is defined in `decidim-core/lib/decidim/component_manifest.rb`:

  ```rb
  # The cell to use to render the card of a resource.
  attribute :card, String
  ```

  In your `decidim-<component>/lib/decidim/<component>/component.rb` register the cell value:

  ```rb
  component.card = "decidim/<component>s/<component>"
  ```

- The **Cell Class**, following the convention will reside in `decidim-<component>s/app/cells/decidim/<component>s/<component>_cell.rb`:

  ```rb
  module Decidim
    module <Component>s
      class <Component>Cell < Decidim::ViewModel
        def show
          render # renders decidim-<component>s/app/cells/decidim/<component>s/<component>
        end
      end
    end
  end
  ```

- The **Cell Views** will be in the `decidim-<component>s/app/cells/decidim/<component>s/<component>` and defaults to `show.erb`

## More Info

- [cells/README.md at master · trailblazer/cells](https://github.com/trailblazer/cells/blob/master/README.md)
- [Trailblazer: Cells](http://trailblazer.to/gems/cells/) / [Trailblazer: Cells API](http://trailblazer.to/gems/cells/api.html)
- [Introduction to Cells: A Better View Layer for Rails — SitePoint](https://www.sitepoint.com/introduction-to-cells-a-better-view-layer-for-rails/)
