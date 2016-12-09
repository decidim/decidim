// ---------------------------------------
// Test Environment Setup
// ---------------------------------------
import sinon from 'sinon/pkg/sinon';
import chai from 'chai';
import sinonChai from 'sinon-chai';
import chaiAsPromised from 'chai-as-promised';
import chaiEnzyme from 'chai-enzyme';
// 
chai.use(sinonChai)
chai.use(chaiAsPromised)
chai.use(chaiEnzyme())
// 
global.chai = chai
global.sinon = sinon
global.expect = chai.expect
global.should = chai.should()

// ---------------------------------------
// Require Tests
// ---------------------------------------
let testsContext = require.context('./comments/', true, /\.test\.jsx?$/);
testsContext.keys().forEach(testsContext);
