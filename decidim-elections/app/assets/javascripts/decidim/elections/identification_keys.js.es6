/**
 * IdentificationKeys component.
 */

((exports) => {
  class IdentificationKeys {
    constructor(trusteeId, storedPublicKey) {
      this.format = 'jwk';
      this.algorithm = {
        name: 'RSASSA-PKCS1-v1_5',
        modulusLength: 4096,
        publicExponent: new Uint8Array([0x01, 0x00, 0x01]),
        hash: {name: 'SHA-256'}
      };
      this.usages = ['sign'];
      this.publicKeyAttrs = ['alg', 'e', 'kty', 'n'];
      this.jwtHeader = this._encode64(JSON.stringify({alg: 'RS256', typ: 'JWT'}));

      this.trusteeId = trusteeId;
      this.privateKey = null;
      this.publicKey = null;
      this.storedPublicKey = JSON.parse(storedPublicKey || null);
      this.keyIdentifier = `${trusteeId}_identification_key`;
      this.browserSupport = this._checkBrowserSupport();
      this.textEncoder = new TextEncoder('utf-8');

      this.dbName = 'identification_keys';
      this.dbVersion = 1;
      this.presentPromise = this._read();
    }

    present(then) {
      this.presentPromise.then(() => {
        if (!this._matchesStoredPublicKey(this.publicKey)) {
          this.reset().then(then(false));
        } else {
          then(this.browserSupport && this.privateKey !== null);
        }
      });
    }

    async generate() {
      if(!this.browserSupport || this.storedPublicKey) {
        return false;
      }

      return new Promise((resolve, reject) => {
        this.crypto.subtle.generateKey(this.algorithm, true, this.usages).then((keyPair) => {
          this.crypto.subtle.exportKey(this.format, keyPair.privateKey).then((jwk) => {
            this.publicKey = this._publicKeyFromPrivateKey(jwk);
            var element = document.createElement('a');
            element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(JSON.stringify(jwk)));
            element.setAttribute('download', this.keyIdentifier + '.jwk');
            element.style.display = 'none';
            document.body.appendChild(element);
            element.click();
            document.body.removeChild(element);
            resolve(true);
          }).catch(this._handleErrors);
        });
      });
    }

    async upload() {
      if(!this.browserSupport || this.privateKey !== null) {
        return false;
      }

      return new Promise((resolve, reject) => {
        var element = document.createElement('input');
        element.setAttribute('type', 'file');
        element.style.display = 'none';

        element.addEventListener('change', (e) => {
          const reader = new FileReader();
          reader.readAsText(event.target.files[0]);
          reader.onload = (event) => {
            let jwk;
            try {
              jwk = JSON.parse(event.target.result);
            } catch (error) {
              return reject('invalid_format');
            }

            this.crypto.subtle.importKey(this.format, jwk, this.algorithm, false, this.usages).then((privateKey) => {
              const uploadedPublicKey = this._publicKeyFromPrivateKey(jwk);
              if (!this._matchesStoredPublicKey(uploadedPublicKey)) {
                reject('invalid_public_key');
                return;
              }
              this.publicKey = uploadedPublicKey;
              this.privateKey = privateKey;
              this._save();
              return resolve(true);
            }).catch((event) => {
              return reject('invalid_key');
            });
          }
        });
        document.body.appendChild(element);
        element.click();
        document.body.removeChild(element);
      });
    }

    reset() {
      this.privateKey = this.publicKey = null;
      return this._clear();
    }

    sign(payload) {
      if(!this.browserSupport || this.privateKey == null) {
        return false;
      }

      const data = this.jwtHeader + '.' + this._encode64(JSON.stringify(payload));
      const signature = this.crypto.subtle.sign(this.algorithm.name, this.privateKey, this.textEncoder.encode(data));

      return data + '.' + this._encode64(signature);
    }

    _checkBrowserSupport() {
      this.indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB;
      this.crypto = window.crypto || window.msCrypto;
      return window.indexedDB && window.crypto;
    }

    _handleErrors(e) {
      throw e;
    };

    _publicKeyFromPrivateKey(jwk) {
      return Object.keys(jwk).filter(key => this.publicKeyAttrs.includes(key))
                             .reduce((obj, key) => {
                               obj[key] = jwk[key];
                               return obj;
                             }, {});
    }

    _matchesStoredPublicKey(publicKey) {
      return publicKey &&
             this.storedPublicKey &&
             this._encode64(JSON.stringify(publicKey)) === this._encode64(JSON.stringify(this.storedPublicKey));
    }

    _encode64(payload) {
      return btoa(unescape(encodeURIComponent(payload))).replace(/=/g, '')
                                                        .replace(/\+/g, '-')
                                                        .replace(/\//g, '_');
    }

    async _read(name, version) {
      return this._useDb('readonly', (store) => {
        store.get(this.keyIdentifier)
             .onsuccess = (event) => {
               if (event.target.result) {
                 this.privateKey = event.target.result.privateKey;
                 this.publicKey = event.target.result.publicKey;
               }
             };
      });
    }

    async _save() {
      return this._useDb('readwrite', (store) => {
        store.add({
          'privateKey': this.privateKey,
          'publicKey': this.publicKey
        }, this.keyIdentifier);
      });
    }



    async _clear() {
      return this._useDb('readwrite', (store) => {
        store.delete(this.keyIdentifier);
      });
    }

    async _useDb(mode, operation) {
      return new Promise((resolve, reject) => {
        var db = null;
        const dbReq = this.indexedDB.open(this.dbName, this.dbVersion);

        dbReq.onerror = (event) => {
          db = null;
          reject();
        };

        dbReq.onupgradeneeded = (event) => {
          db = dbReq.result;
          var objectStore = db.createObjectStore('IdentificationKeys');
        };

        dbReq.onsuccess = (event) => {
          db = dbReq.result;
          const tx = db.transaction(['IdentificationKeys'], mode);

          operation(tx.objectStore('IdentificationKeys'));

          tx.oncomplete = (event) => {
            db.close();
            resolve(true);
          }
        }
      });
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.IdentificationKeys = IdentificationKeys;
})(window)

