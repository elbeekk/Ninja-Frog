'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "ece3311e19cced64da79a71dea3a6510",
"assets/AssetManifest.json": "d0eb39da39ebd2568e166e6e836ca21d",
"assets/assets/audio/hitHurt.wav": "83cd5ed700c35f84f0e2eb81a6ac91cc",
"assets/assets/audio/jump.wav": "5f013eef46e48d575992ebf06315faee",
"assets/assets/audio/pickupCoin.wav": "c28926b1064fa046db3bac58a77af277",
"assets/assets/audio/powerUp.wav": "38e2caa51ae6580292f199228dba93a1",
"assets/assets/images/Background/Blue.png": "f86e07aab82505fc49710152f83cc385",
"assets/assets/images/Background/Brown.png": "45c9c887fa73b0ade76974de63ab9157",
"assets/assets/images/Background/Gray.png": "31fb9bc36ec926ee64d999d3387b7e09",
"assets/assets/images/Background/Green.png": "e6eeace8a9d516f2e9768e5228e824fb",
"assets/assets/images/Background/Pink.png": "31b5e360eb9610c58138bb7cfdfb96a1",
"assets/assets/images/Background/Purple.png": "f8cc6aa8fd738e6e4db8b6607b7e6c37",
"assets/assets/images/Background/Yellow.png": "c3f96416e21f366bc0c3635ce5b530d5",
"assets/assets/images/Buttons/Joystick.png": "b0913c7edd79364c257f5ac156176131",
"assets/assets/images/Buttons/JumpButton.png": "2e150e827d3d69278f0f28e0754ee9b2",
"assets/assets/images/Buttons/Knob.png": "deef0b8d39b664dd78c12f8cccef37a7",
"assets/assets/images/Items/Checkpoints/Checkpoint/Checkpoint%2520(Flag%2520Idle)(64x64).png": "dd8752c20a0f69ab173f1ead16044462",
"assets/assets/images/Items/Checkpoints/Checkpoint/Checkpoint%2520(Flag%2520Out)%2520(64x64).png": "c4730e5429a75691e2d2a9351c76738e",
"assets/assets/images/Items/Checkpoints/Checkpoint/Checkpoint%2520(No%2520Flag).png": "9126203dc833ec3b7dfb7a05e41910e5",
"assets/assets/images/Items/Fruits/Apple.png": "de3dbfa7d33e6bb344d0560e36d8bf53",
"assets/assets/images/Items/Fruits/Bananas.png": "03466a1dbd95724e705efe17e72c1c4e",
"assets/assets/images/Items/Fruits/Cherries.png": "fc2a60aee885c33d0d10e643157213e4",
"assets/assets/images/Items/Fruits/Collected.png": "0aa8cdedde5af58d5222c2db1e0a96de",
"assets/assets/images/Items/Fruits/Kiwi.png": "3d903dd9bf3421c31a5373b0920c876e",
"assets/assets/images/Items/Fruits/Melon.png": "eb6f978fbf95d76587bcf656c649540b",
"assets/assets/images/Items/Fruits/Orange.png": "60e0f68620c442b9403a477bbe3588ed",
"assets/assets/images/Items/Fruits/Pineapple.png": "0740bf84a38504383c80103d60582217",
"assets/assets/images/Items/Fruits/Strawberry.png": "568a3f91b8f6102f1b518c1aba0e8e09",
"assets/assets/images/Main%2520Characters/Appearing%2520(96x96).png": "9449bf1f8d68ac08331aa091d6095e34",
"assets/assets/images/Main%2520Characters/Desappearing%2520(96x96).png": "1284313649da02eccc0d3ed6796996a3",
"assets/assets/images/Main%2520Characters/Mask%2520Dude/Double%2520Jump%2520(32x32).png": "5afb26aa4240eff1eab105eb3263ab83",
"assets/assets/images/Main%2520Characters/Mask%2520Dude/Fall%2520(32x32).png": "469d2d7814fa8258325eb5d305808315",
"assets/assets/images/Main%2520Characters/Mask%2520Dude/Hit%2520(32x32).png": "d03a7bbce7fbda59dd057397f86a8899",
"assets/assets/images/Main%2520Characters/Mask%2520Dude/Idle%2520(32x32).png": "29c95dbb63a9bf44c42821aa0cf49de8",
"assets/assets/images/Main%2520Characters/Mask%2520Dude/Jump%2520(32x32).png": "99da59b514370539951a76ba1fe51821",
"assets/assets/images/Main%2520Characters/Mask%2520Dude/Run%2520(32x32).png": "b04bbc82dc692516a4b13c0d9d5b9ebd",
"assets/assets/images/Main%2520Characters/Mask%2520Dude/Wall%2520Jump%2520(32x32).png": "552254b40eac6d10d2c3d779edb92116",
"assets/assets/images/Main%2520Characters/Ninja%2520Frog/Double%2520Jump%2520(32x32).png": "351c1df6eb5ac94209e8e490ab816879",
"assets/assets/images/Main%2520Characters/Ninja%2520Frog/Fall%2520(32x32).png": "ef8f3627041b7ae2a1dc76dfc3e419f3",
"assets/assets/images/Main%2520Characters/Ninja%2520Frog/Hit%2520(32x32).png": "4c1ba2bf4e576409abbbd1aacc91d51d",
"assets/assets/images/Main%2520Characters/Ninja%2520Frog/Idle%2520(32x32).png": "cb655be6f9354444720c7ce1dbd61dae",
"assets/assets/images/Main%2520Characters/Ninja%2520Frog/Jump%2520(32x32).png": "4f048ccbc783c8eb3824be9651da8a34",
"assets/assets/images/Main%2520Characters/Ninja%2520Frog/Run%2520(32x32).png": "fb191b4e6ac599286c38e496a700cfd2",
"assets/assets/images/Main%2520Characters/Ninja%2520Frog/Wall%2520Jump%2520(32x32).png": "37ec0be0f82c3750a07efa558c032ee7",
"assets/assets/images/Main%2520Characters/Pink%2520Man/Double%2520Jump%2520(32x32).png": "c76baa04d956c9d985c79643d7b2f672",
"assets/assets/images/Main%2520Characters/Pink%2520Man/Fall%2520(32x32).png": "a20bd61d76132e4301fcfe7aa02ca9ba",
"assets/assets/images/Main%2520Characters/Pink%2520Man/Hit%2520(32x32).png": "5d93268a09fb2959e1755da4ba201f9e",
"assets/assets/images/Main%2520Characters/Pink%2520Man/Idle%2520(32x32).png": "1b35f85f1241dc1f0597cafbe1eac7f6",
"assets/assets/images/Main%2520Characters/Pink%2520Man/Jump%2520(32x32).png": "cafaf2f48f36c9a6655a37f9c1c47b4a",
"assets/assets/images/Main%2520Characters/Pink%2520Man/Run%2520(32x32).png": "25fcce89dfb6673a81d384091c87353d",
"assets/assets/images/Main%2520Characters/Pink%2520Man/Wall%2520Jump%2520(32x32).png": "955d352171a2b666ae705b6205856ce1",
"assets/assets/images/Main%2520Characters/Virtual%2520Guy/Double%2520Jump%2520(32x32).png": "612926916a3e8c5deff2023722c465ac",
"assets/assets/images/Main%2520Characters/Virtual%2520Guy/Fall%2520(32x32).png": "5eb8c32845fad5fcc7794247eb91aed0",
"assets/assets/images/Main%2520Characters/Virtual%2520Guy/Hit%2520(32x32).png": "bbd39134a77e658b0b9b64ded537972c",
"assets/assets/images/Main%2520Characters/Virtual%2520Guy/Idle%2520(32x32).png": "1cb575929ac10fe13dfafa61d78ba28d",
"assets/assets/images/Main%2520Characters/Virtual%2520Guy/Jump%2520(32x32).png": "f28e95fc98b251913baf3a21d5602381",
"assets/assets/images/Main%2520Characters/Virtual%2520Guy/Run%2520(32x32).png": "016f388a07f71a930fd79a7a806d5da8",
"assets/assets/images/Main%2520Characters/Virtual%2520Guy/Wall%2520Jump%2520(32x32).png": "76cbdd4a22d50bd65ac02be8a5eb1547",
"assets/assets/images/Terrain/Terrain%2520(16x16).png": "df891f02449c0565d51e2bf7823a0e38",
"assets/assets/images/Traps/Saw/Chain.png": "69669f8f421b508058cdf1232dc49e28",
"assets/assets/images/Traps/Saw/Off.png": "66d27386fec46e0b052941957d9bdc22",
"assets/assets/images/Traps/Saw/On%2520(38x38).png": "817477a39df8b330334e3866c1cb574b",
"assets/assets/tiles/level_01.tmx": "79331efabcdb20539a5fa8bd272e4599",
"assets/assets/tiles/level_02.tmx": "02ceabbb801ce93f9757e38eae8385cd",
"assets/assets/tiles/pixel_adventure.tiled-project": "f569bfd3353c5a0faa26a765cae42f0d",
"assets/assets/tiles/pixel_adventure.tiled-session": "d66d248e1c2db2633f09830de38ed22d",
"assets/assets/tiles/pixel_adventure.tsx": "662ef85cb559cb7a910195e735f5a8b5",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/NOTICES": "c5efb0de2b7528e058a457f85ac064ea",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"canvaskit/canvaskit.js": "bbf39143dfd758d8d847453b120c8ebb",
"canvaskit/canvaskit.wasm": "42df12e09ecc0d5a4a34a69d7ee44314",
"canvaskit/chromium/canvaskit.js": "96ae916cd2d1b7320fff853ee22aebb0",
"canvaskit/chromium/canvaskit.wasm": "be0e3b33510f5b7b0cc76cc4d3e50048",
"canvaskit/skwasm.js": "95f16c6690f955a45b2317496983dbe9",
"canvaskit/skwasm.wasm": "1a074e8452fe5e0d02b112e22cdcf455",
"canvaskit/skwasm.worker.js": "51253d3321b11ddb8d73fa8aa87d3b15",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "6b515e434cea20006b3ef1726d2c8894",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "887a68cf406a229bd98da4800427c3d1",
"/": "887a68cf406a229bd98da4800427c3d1",
"main.dart.js": "202a9ff5250eb6b4d7d2f1186476bb9b",
"manifest.json": "a7e8fdfa6e2053e0644911ebea1b7a9c",
"version.json": "a8f963d047713aa3fb6c232bb9e1ca27"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
