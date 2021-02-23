(()=>{"use strict";var e={d:(r,t)=>{for(var s in t)e.o(t,s)&&!e.o(r,s)&&Object.defineProperty(r,s,{enumerable:!0,get:t[s]})},o:(e,r)=>Object.prototype.hasOwnProperty.call(e,r),r:e=>{"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})}},r={};e.r(r),e.d(r,{TrusteeWrapperAdapter:()=>s,VoterWrapperAdapter:()=>o});class t{processPythonCodeOnWorker(e,r){return new Promise(((t,s)=>{this.worker.onmessage=e=>{t(e.data.results)},this.worker.onerror=e=>{console.error(e),s(e)},this.worker.postMessage({python:e,...r})}))}}class s extends t{constructor({trusteeId:e,workerUrl:r}){super(),this.trusteeId=e,this.worker=new Worker(r),this.worker.postMessage({python:"\n        from js import trustee_id\n        from decidim.electionguard.trustee import Trustee\n        trustee = Trustee(trustee_id)\n      ",trustee_id:this.trusteeId})}async processMessage(e,r){const t=await this.processPythonCodeOnWorker("\n      import json\n      from js import message_type, decoded_data\n      trustee.process_message(message_type, json.loads(decoded_data))\n    ",{message_type:e,decoded_data:JSON.stringify(r)});if(t){const{message_type:e,content:r}=t;return{messageType:e,content:r}}return t}isFresh(){return this.processPythonCodeOnWorker("\n      trustee.is_fresh()\n    ")}backup(){return this.processPythonCodeOnWorker("\n      trustee.backup().hex()\n    ")}restore(e){return this.processPythonCodeOnWorker("\n      from js import state\n\n      trustee = Trustee.restore(bytes.fromhex(state))\n      True\n    ",{state:e})}isKeyCeremonyDone(){return this.processPythonCodeOnWorker("\n      trustee.is_key_ceremony_done()\n    ")}isTallyDone(){return this.processPythonCodeOnWorker("\n      trustee.is_tally_done()\n    ")}}class o extends t{constructor({voterId:e,workerUrl:r}){super(),this.voterId=e,this.worker=new Worker(r),this.worker.postMessage({python:"\n        from js import voter_id\n        from decidim.electionguard.voter import Voter\n        voter = Voter(voter_id)\n      ",voter_id:this.voterId})}async processMessage(e,r){const t=await this.processPythonCodeOnWorker("\n      import json\n      from js import message_type, decoded_data\n      voter.process_message(message_type, json.loads(decoded_data))\n    ",{message_type:e,decoded_data:JSON.stringify(r)});if(t){const{message_type:e,content:r}=t;return{messageType:e,content:r}}return t}async encrypt(e){return{auditableData:null,encryptedData:await this.processPythonCodeOnWorker("\n      from js import plain_vote\n      voter.encrypt(plain_vote)\n    ",{plain_vote:e})}}}window.electionGuardVotingScheme=r})();