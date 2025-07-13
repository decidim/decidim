/* eslint id-length: ["error", { "exceptions": ["$"] }] */

import createOptionAttachedInputs from "src/decidim/forms/option_attached_inputs.component"
import createMaxChoicesAlertComponent from "src/decidim/forms/max_choices_alert.component"

/**
 * A plain JavaScript component that handles questions from polls in meetings:
 *   - fetches them via Ajax
 *   - enables a polling to automatically update them
 *
 * @class
 * @augments Component
 */

// This is necessary for testing purposes
const $ = window.$;

// Default question states
const OPEN = "open";
const CLOSED = "closed";

export default class PollComponent {
  constructor($element, config, $counter = null) {
    this.$element = $element;
    this.$counter = $counter;
    this.questionsUrl = config.questionsUrl;
    this.pollingInterval = config.pollingInterval || 10000;
    this.mounted = false;
    this.questions = {};
    this.questionsStatuses = {};
    this.responsesStatuses = {};
  }

  /**
   * Returns if the component is mounted or not
   * @public
   * @returns {Void} - Returns nothing
   */
  isMounted() {
    return this.mounted;
  }

  /**
   * Handles the logic for mounting the component
   * @public
   * @returns {Void} - Returns nothing
   */
  mountComponent() {
    if (this.$element.length > 0 && !this.mounted) {
      this.mounted = true;
      this._fetchQuestions();
    }
  }

  unmountComponent() {
    if (this.mounted) {
      this.mounted = false;
      this._stopPolling();
      this.$element.html("");
    }
  }

  /**
   * Performs the ajax call that updates the list of questions
   * Before, stores the current questions states to apply them after the ajax call has
   * been completed
   * @private
   * @returns {Void} - Returns nothing
   */
  _fetchQuestions() {
    $("#content").addClass("spinner-container")

    // Store current questions state (open / closed) before overwriting them with the Ajax call
    // response.
    this._storeQuestionState(this.$element);

    $.ajax({
      url: this.questionsUrl,
      method: "GET",
      contentType: "application/javascript"
    }).done(() => {
      this._updateCounter();
      this._setQuestionsState(this.$element);
      this._pollQuestions();
      this._addValidations();

      $("#content").removeClass("spinner-container")
    });
  }

  /**
   * Iterates over all existing questions and stores the state in an internal attribute.
   * @private
   * @param {jQuery} $parent - The HTML content for the questionnaire.
   * @returns {Void} - Returns nothing
   */
  _storeQuestionState($parent) {
    $("[data-question]", $parent).each((_i, el) => {
      const $el = $(el);
      const questionId = $el.data("question");
      const elForm = $el.find("form");

      this.questionsStatuses[questionId] = $el.data("status");
      if (elForm.length > 0) {
        this.responsesStatuses[questionId] = Object.fromEntries(new FormData(elForm[0]));
      }
      if ($el[0].open === true) {
        this.questions[questionId] = OPEN;
      } else {
        this.questions[questionId] = CLOSED;
      }
    });
  }

  /**
   * Initializes the states of all the questions.
   * @private
   * @param {jQuery} $parent - The HTML container for the questionnaire.
   * @returns {Void} - Returns nothing
   */
  _setQuestionsState($parent) {
    $("[data-question]", $parent).each((_i, el) => {
      this._setQuestionState($(el));
    });
  }

  /**
   * Initializes the state of a single question with two types of modifications:
   *   - sets the is-new class if the question is new (does not exist in the internal list)
   *   - sets the state to open if it was open in the internal list
   * @private
   * @param {jQuery} $el - The HTML container for the questionnaire.
   * @returns {Void} - Returns nothing
   */
  _setQuestionState($el) {
    const questionId = $el.data("question");
    // Current question state
    const state = this.questions[questionId];
    const questionStatus = this.questionsStatuses[questionId];
    const responsesStatuses = this.responsesStatuses[questionId];

    // New questions have a special class
    if (!state) {
      $el.addClass("is-new");
    } else if (state === OPEN) {
      $el.prop(OPEN, true);
    }

    if ($el.data("status") === CLOSED && $el.data("status") !== questionStatus) {
      $el.data("status", `${CLOSED}-new`);
      document.getElementById(`closed-announcement-${questionId}`).hidden = false;
    }

    if (responsesStatuses) {
      for (const [key, value] of Object.entries(responsesStatuses)) {
        if (key.includes("[choices]")) {
          $el.find(`[name='${key}'][value='${value}']`).prop("checked", true);
        }
      }
    }
  }

  /**
   * Sets a timeout to poll new questions.
   * @private
   * @returns {Void} - Returns nothing
   */
  _pollQuestions() {
    this._stopPolling();

    this.pollTimeout = setTimeout(() => {
      this._fetchQuestions();
    }, this.pollingInterval);
  }

  /**
   * Stops polling for new questions.
   * @private
   * @returns {Void} - Returns nothing
   */
  _stopPolling() {
    if (this.pollTimeout) {
      clearTimeout(this.pollTimeout);
    }
  }

  /**
   * Updates the counter with the number of questions returned in the Ajax call
   * @private
   * @returns {Void} - Returns nothing
   */
  _updateCounter() {
    if (this.$counter) {
      const questionsCount = this.$element.find("details").length;
      this.$counter.html(`(${questionsCount})`);
    }
  }

  _addValidations() {
    $(".js-radio-button-collection, .js-check-box-collection").each((idx, el) => {
      createOptionAttachedInputs({
        wrapperField: $(el),
        controllerFieldSelector: "input[type=radio], input[type=checkbox]",
        dependentInputSelector: "input[type=text], input[type=hidden]"
      });
    });

    $.unique($(".js-check-box-collection").parents("[data-max-choices]")).each((idx, el) => {
      const maxChoices = $(el).data("max-choices");
      if (maxChoices) {
        createMaxChoicesAlertComponent({
          wrapperField: $(el),
          controllerFieldSelector: "input[type=checkbox]",
          controllerCollectionSelector: ".js-check-box-collection",
          alertElement: $(el).find(".max-choices-alert"),
          maxChoices: maxChoices
        });
      }
    });
  }
}
