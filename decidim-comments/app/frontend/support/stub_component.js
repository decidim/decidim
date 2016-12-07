/* eslint-disable no-param-reassign */

/**
 * A helper function to stub the `propTypes` and `fragments` of a component.
 * Useful for testing isolated components so the children propTypes are not
 * evaluated.
 * @param {ReactComponent} componentClass - A component constructor function or class
 * @param {Object} options - An object which properties are used to stub component properties.
 * @returns {ReactCompnent} - A component with some properties stubbed
 */
const stubComponent = function(componentClass, options = {}) {
  let originalPropTypes = {};
  let originalFragments = {};

  beforeEach(function() {
    originalPropTypes = componentClass.propTypes;
    originalFragments = componentClass.fragments;

    componentClass.propTypes = options.propTypes || {};
    componentClass.fragments = options.fragments || {};
  });

  afterEach(function() {
    componentClass.propTypes = originalPropTypes;
    componentClass.fragments = originalFragments;
  });
};

export default stubComponent;
