// jslint:disable:no-param-reassign
const stubComponent = function(componentClass) {
  let originalPropTypes = {};

  beforeEach(function() {
    originalPropTypes = componentClass.propTypes;

    componentClass.propTypes = {};
  });

  afterEach(function() {
    componentClass.propTypes = originalPropTypes;
  });
};

export default stubComponent;
