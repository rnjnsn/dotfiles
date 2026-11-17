// Load chrome/userChrome.css and chrome/userContent.css (Gruvbox interface)
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
// Keep the built-in dark theme as the base underneath the CSS
user_pref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org");
user_pref("browser.theme.toolbar-theme", 0);
user_pref("browser.theme.content-theme", 0);

// ===== 2026-11-16 keyboard-first / suckless tune =====
// Backup of the previous file: ~/.local/share/tuneup-backup-20261115/firefox-20261116/
// Firefox re-applies this file on every start. To undo one line, delete it here, then reset the pref in about:config.

// --- behaviour
user_pref("browser.startup.page", 3);                      // restore last session
user_pref("browser.tabs.closeWindowWithLastTab", false);   // closing the last tab with x does not kill the window
user_pref("browser.ctrlTab.sortByRecentlyUsed", true);     // Ctrl+Tab = alt-tab between recent tabs
user_pref("ui.key.menuAccessKeyFocuses", false);           // tapping Alt doesn't pop the menubar
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.download.always_ask_before_handling_new_types", false);
user_pref("browser.urlbar.trimURLs", false);               // show the full URL
user_pref("browser.urlbar.update2.engineAliasRefresh", true); // "Add" button for custom engines in Settings > Search

// --- tiling WM: video "fullscreen" fills the tile only; Super+f gives real fullscreen
user_pref("full-screen-api.ignore-widgets", true);
user_pref("full-screen-api.warning.timeout", 0);
user_pref("full-screen-api.transition-duration.enter", "0 0");
user_pref("full-screen-api.transition-duration.leave", "0 0");

// --- compact UI
user_pref("browser.compactmode.show", true);
user_pref("browser.uidensity", 1);

// --- Intel Arc: hardware video decode via VA-API (intel-media-driver installed)
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);

// --- debloat: sponsored and Pocket content, telemetry, studies
user_pref("extensions.pocket.enabled", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
user_pref("browser.urlbar.suggest.trending", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("browser.discovery.enabled", false);
user_pref("browser.contextual-password-manager.enabled", false);  // no passwords (key) button in the sidebar; Ctrl+Shift+L browserpass still works
