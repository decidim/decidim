# Data Picker

Select2 has been removed from the project in the benefit of a custom selector. The reasons for this change can be found in (this)[https://github.com/decidim/decidim/pull/2330] PR. The summary is that there are many kinds of data and many better usable ways to select this data than the simple select provided by html. Also there are some problems with the responsiveness of Select2.

Current Decidim's selector is inspired in [this](https://medium.com/@mibosc/responsive-design-why-and-how-we-ditched-the-good-old-select-element-bc190d62eff5) article.

Data Picker is a selector thought to be reusable in many contexts and kinds of data. The idea behind it is a reusable widget that opens a popup where the user will perform a given selection and on finish this selection is returned to the source widget in the main page. The popup is accompained by a semitransparent layer behind it to blur the background and keep the user concentrated in the current action, the selection.

## Artifacts
Data Picker is composed by 2 visual artifacts, plus the javascript and one controller action for each selection type:
- widget: the first visual artifact is the widget that encapsulates the main Data Picker functionality. This widget manages the rendering of __the button__ that opens the selector and __the popup__. This button is managed via ujs (Unobtrusive JavaScript). The popup is empty and must be filled with a selection partial.
- **selection functionality** partial: There are many ways to select things (and many kinds of things to select). Thus, the selection functionality can be customized via a selection partial which will be rendered inside the widget's popup. This partial is supplied to the widget via ajax.
- **controller ajax action**: An ajax action will send the content of the popup in an html partial.

## How to
