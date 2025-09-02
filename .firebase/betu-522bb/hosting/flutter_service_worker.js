'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "4c286040b2351d7774638ba8ba069c61",
"assets/AssetManifest.bin.json": "a000b97d513ea99da3fa0b06ac060346",
"assets/AssetManifest.json": "e85f9e1c539f35edcecdec262157788a",
"assets/assets/category/account.png": "e743cf461e7c9aae95730cee3a7704b6",
"assets/assets/category/certificate.png": "cbba8b47ccf16a7a1b81e9245bc47c49",
"assets/assets/category/gongmuwon.png": "855890d8e6a79695adf64486fc874ba4",
"assets/assets/category/leet.png": "f56564a0fe1e8dd1d54a4fc7ba9ebfce",
"assets/assets/category/self.png": "b3cfe673af81754289c523135fd719dd",
"assets/assets/category/suneung.png": "8b94cd490d06410e5e30f6afeaf84db6",
"assets/assets/category/toeic.png": "a09cff56f599ce4970b1010323a254c3",
"assets/assets/category/university.png": "ad5a9ecc3f36032d709aebd499738ca3",
"assets/assets/fonts/Freesentation-3Light.ttf": "180e8d02298abb08961dcf2ba03fc5e1",
"assets/assets/fonts/Freesentation-4Regular.ttf": "0e3b4b9ab43865658c69bd57db626839",
"assets/assets/fonts/Freesentation-5Medium.ttf": "a0f1f20e266142445cd933f3a3031d67",
"assets/assets/fonts/Freesentation-6SemiBold.ttf": "8f548c57f9a7936acc35168c76f774a3",
"assets/assets/fonts/Freesentation-7Bold.ttf": "7c88a4a74dbad732e5981db5151e3330",
"assets/assets/fonts/Freesentation-8ExtraBold.ttf": "8bdd97fca1d284f9c7babf3e995fba7c",
"assets/assets/fonts/Freesentation-9Black.ttf": "20614a91083b461a8f44e58275ffba34",
"assets/assets/images/betu_bottom_icon.png": "38f159fa94c99e2b444ace29c5a9598b",
"assets/assets/images/BETU_challenge_background.png": "1330d04c60da76afed9f59ba26fbf7d3",
"assets/assets/images/betu_happy.png": "f8fa808e890ef3c5aebc6bc2afa29fdf",
"assets/assets/images/betu_hot.png": "3b3c77850664887ec65d71af428b83f2",
"assets/assets/images/BETU_letters.png": "28bcba521150c20612fe7024742b6361",
"assets/assets/images/BETU_mainlogo.png": "8f0f1da24091834f84ff75c4973604e2",
"assets/assets/images/betu_upperbar.png": "ae236b39b86202247a853b8dc2671c6b",
"assets/assets/images/bet_u_bot.jpg": "3466fb878a25552d79b368f4e263c86b",
"assets/assets/images/frame.png": "776859e598d4bc3034687d4a2fbf2ba6",
"assets/assets/images/happy_lettuce.png": "3262f806766f6f836eee1dabf5c0c17d",
"assets/assets/images/image_add.png": "5d7d0407a44adac932fb68f34bdd9668",
"assets/assets/images/lettuce_profile.png": "89cd0e6b02f25c6a3ab8076bfb8f821b",
"assets/assets/images/normal_lettuce.png": "6be003b81a470148ac00ec53cc82033c",
"assets/assets/images/point/background/bg1.png": "5c9a67efb133409e6206a0f9dcd8e78d",
"assets/assets/images/point/background/bg2.png": "efa51ac1bdd624fb2669ae26dc6e68b8",
"assets/assets/images/point/background/bg3.png": "5bfe6c983b76f60417f83273f30ac82c",
"assets/assets/images/point/background/bg4.png": "7483d0e5cc3a9a73517a18ecaa7f8226",
"assets/assets/images/point/point_1Lv.png": "1c75a022b9a71cc4a973b07b311f217f",
"assets/assets/images/point/point_2Lv.png": "204506300f08cf61cde491b90819566c",
"assets/assets/images/point/point_3Lv.png": "d1b8fc26686dd52156d6e207449468bc",
"assets/assets/images/point/point_4Lv.png": "7594c38a3750468649a980a430407b7e",
"assets/assets/images/point_icon.png": "6cb5a3bd7ca7a7e3ab98ab1c57c674d2",
"assets/assets/images/point_icon_x3.png": "db961c4514fe3750fd68ba45599816d6",
"assets/assets/images/red_lettuce.png": "b82ae5f32304245e7c1513d28e0eb222",
"assets/assets/images/trophy.png": "bf01b9a059e8754630637442ec47b837",
"assets/FontManifest.json": "918b6c65a02ed82c9262a7f36c666b18",
"assets/fonts/MaterialIcons-Regular.otf": "0944510e1a9819318fc560273f4570fd",
"assets/NOTICES": "0fabcb34ac93e2033eae14356695ab29",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/packages/flutter_inappwebview_web/assets/web/web_support.js": "509ae636cfdd93e49b5a6eaf0f06d79f",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "ba704adbb9bf8147261863366df4689e",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "2e4d2dfdffcc99b40814b0cd9a096d2c",
"/": "2e4d2dfdffcc99b40814b0cd9a096d2c",
"main.dart.js": "dac94520a662299070eb840837a84bbb",
"manifest.json": "9f38218c9fb4bee8f71e0fcf5eb35b74",
"version.json": "d39b801d6b7c611f8bcd93c65466594a"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
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
