/*! coi-serviceworker v0.1.7 - Guido Zuidhof and contributors, licensed under MIT */
let coepCredentialless = false;
if (typeof window === 'undefined') {
    self.addEventListener("install", () => self.skipWaiting());
    self.addEventListener("activate", (e) => e.waitUntil(self.clients.claim()));
    self.addEventListener("message", (e) => {
        if (e.data && e.data.type === "deregister") {
            self.registration.unregister().then(() => self.clients.matchAll()).then((clients) => {
                clients.forEach((client) => client.navigate(client.url));
            });
        }
    });
    self.addEventListener("fetch", function (e) {
        if (e.request.cache === "only-if-cached" && e.request.mode !== "same-origin") return;
        e.respondWith(
            fetch(e.request).then((res) => {
                if (res.status === 0) return res;
                const newHeaders = new Headers(res.headers);
                newHeaders.set("Cross-Origin-Embedder-Policy", coepCredentialless ? "credentialless" : "require-corp");
                newHeaders.set("Cross-Origin-Opener-Policy", "same-origin");
                return new Response(res.body, { status: res.status, statusText: res.statusText, headers: newHeaders });
            }).catch((e) => console.error(e))
        );
    });
} else {
    (() => {
        const reloadedBySelf = window.sessionStorage.getItem("coiReloadedBySelf");
        window.sessionStorage.removeItem("coiReloadedBySelf");
        const coepDegrading = reloadedBySelf === "coepdegrade";
        if (window.crossOriginIsolated !== false || reloadedBySelf) return;
        if (!window.isSecureContext) {
            console.log("COOP/COEP Service Worker not registered, secure context is required.");
            return;
        }
        if (!("serviceWorker" in navigator)) {
            console.log("COOP/COEP Service Worker not registered, Service Workers are not supported.");
            return;
        }
        navigator.serviceWorker.register(window.document.currentScript.src).then(
            (registration) => {
                registration.addEventListener("updatefound", () => {
                    if (registration.installing && !navigator.serviceWorker.controller) {
                        window.sessionStorage.setItem("coiReloadedBySelf", coepDegrading ? "coepdegrade" : "");
                        window.location.reload();
                    }
                });
                if (registration.active && !navigator.serviceWorker.controller) {
                    window.sessionStorage.setItem("coiReloadedBySelf", coepDegrading ? "coepdegrade" : "");
                    window.location.reload();
                }
            },
            (err) => console.error("COOP/COEP Service Worker failed to register:", err)
        );
    })();
}
