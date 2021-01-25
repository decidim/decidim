/**
 * IdentificationKeys component.
 */

((exports) => {
  class IdentificationKeys {
    constructor(trusteeUniqueId, storedPublicKey) {
      this.format = "jwk";
      this.algorithm = {
        name: "RSASSA-PKCS1-v1_5",
        modulusLength: 4096,
        publicExponent: new Uint8Array([0x01, 0x00, 0x01]),
        hash: {name: "SHA-256"}
      };
      this.usages = ["sign"];
      this.publicKeyAttrs = ["alg", "e", "kty", "n"];
      this.jwtHeader = this._encode64(JSON.stringify({alg: "RS256", typ: "JWT"}));

      this.trusteeUniqueId = trusteeUniqueId;
      this.privateKey = null;
      this.publicKey = null;
      this.storedPublicKey = JSON.parse(storedPublicKey || null);
      this.keyIdentifier = `${trusteeUniqueId}-private-key`;
      this.browserSupport = this._checkBrowserSupport();
      this.textEncoder = new TextEncoder("utf-8");

      this.dbName = "identification_keys";
      this.dbVersion = 1;
      this.presentPromise = this._read();
    }

    present(then) {
      this.presentPromise.then(() => {
        if (this._matchesStoredPublicKey(this.publicKey)) {
          then(this.browserSupport && this.privateKey !== null);
        } else {
          this.reset().then(then(false));
        }
      });
    }

    async generate() {
      if (!this.browserSupport || this.storedPublicKey) {
        return false;
      }

      return new Promise((resolve, reject) => {
        try {
          return this.crypto.subtle.generateKey(this.algorithm, true, this.usages).then((keyPair) => {
            return this.crypto.subtle.exportKey(this.format, keyPair.privateKey).then((jwk) => {
              this.publicKey = this._publicKeyFromPrivateKey(jwk);
              let element = document.createElement("a");
              element.setAttribute("href", `data:text/plain;charset=utf-8,${encodeURIComponent(JSON.stringify(jwk))}`);
              element.setAttribute("download", `${this.keyIdentifier}.jwk`);
              element.style.display = "none";
              document.body.appendChild(element);
              element.click();
              document.body.removeChild(element);
              return resolve();
            }).catch(this._handleErrors);
          });
        } catch (error) {
          return reject();
        }
      });
    }

    async upload() {
      if (!this.browserSupport || this.privateKey !== null) {
        return false;
      }

      return new Promise((resolve, reject) => {
        let element = document.createElement("input");
        element.setAttribute("type", "file");
        element.setAttribute("accept", ".jwk");
        element.style.display = "none";
        document.body.appendChild(element);

        element.addEventListener("change", (event) => {
          document.body.removeChild(element);
          const reader = new FileReader();
          reader.readAsText(event.target.files[0]);
          reader.onload = (readEvent) => {
            let jwk = "";
            try {
              jwk = JSON.parse(readEvent.target.result);
            } catch (error) {
              return reject("invalid_format");
            }

            return this.crypto.subtle.importKey(this.format, jwk, this.algorithm, false, this.usages).then((privateKey) => {
              const uploadedPublicKey = this._publicKeyFromPrivateKey(jwk);
              if (this._matchesStoredPublicKey(uploadedPublicKey)) {
                this.publicKey = uploadedPublicKey;
                this.privateKey = privateKey;
                this._save();
                resolve(true);
              } else {
                reject("invalid_public_key");
              }
            }).catch(() => {
              reject("invalid_key");
            });
          }
        });
        element.click();
      });
    }

    reset() {
      this.privateKey = this.publicKey = null;
      return this._clear();
    }

    async sign(payload) {
      if (!this.browserSupport || this.privateKey === null) {
        return false;
      }

      const data = `${this.jwtHeader}.${this._encode64(JSON.stringify(payload))}`;
      const signature = await this.crypto.subtle.sign(this.algorithm, this.privateKey, this.textEncoder.encode(data));
      return `${data}.${btoa(Reflect.apply(String.fromCharCode, null, new Uint8Array(signature))).replace(/[=]/g, "").replace(/\+/g, "-").replace(/\//g, "_")}`;
    }

    _checkBrowserSupport() {
      this.indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB;
      this.crypto = window.crypto || window.msCrypto;
      return window.indexedDB && window.crypto;
    }

    _handleErrors(error) {
      throw error;
    }

    _publicKeyFromPrivateKey(jwk) {
      return Object.keys(jwk).filter((key) => this.publicKeyAttrs.includes(key)).
        reduce((obj, key) => {
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
      return btoa(unescape(encodeURIComponent(payload))).replace(/[=]/g, "").
        replace(/\+/g, "-").
        replace(/\//g, "_");
    }

    async _read() {
      return this._useDb("readonly", (store) => {
        store.get(this.keyIdentifier).
          onsuccess = (event) => {
            if (event.target.result) {
              this.privateKey = event.target.result.privateKey;
              this.publicKey = event.target.result.publicKey;
            }
          };
      });
    }

    async _save() {
      return this._useDb("readwrite", (store) => {
        store.add({
          "privateKey": this.privateKey,
          "publicKey": this.publicKey
        }, this.keyIdentifier);
      });
    }


    async _clear() {
      return this._useDb("readwrite", (store) => {
        store.delete(this.keyIdentifier);
      });
    }

    async _useDb(mode, operation) {
      return new Promise((resolve, reject) => {
        let db = null;
        const dbReq = this.indexedDB.open(this.dbName, this.dbVersion);

        dbReq.onerror = () => {
          db = null;
          reject();
        };

        dbReq.onupgradeneeded = () => {
          db = dbReq.result;
          db.createObjectStore("IdentificationKeys");
        };

        dbReq.onsuccess = () => {
          db = dbReq.result;
          const tx = db.transaction(["IdentificationKeys"], mode);

          operation(tx.objectStore("IdentificationKeys"));

          tx.oncomplete = () => {
            db.close();
            resolve();
          }
        }
      });
    }
  }

  exports.Decidim = exports.Decidim || {};
  exports.Decidim.IdentificationKeys = IdentificationKeys;
})(window)

