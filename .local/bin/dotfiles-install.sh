#!/bin/bash
set -euo pipefail

cd ~

echo '==' installing core packages
if pacman -Q paru &> /dev/null; then
    paru -S --needed base-devel git alacritty qview freetube-bin prismlauncher \
        vscodium-bin wl-clipboard ttf-{liberation,ibm-plex,hack,aptos,dejavu} apple-fonts \
        shellcheck-bin splix steam tesseract tesseract-data-{eng,jpn,tur} tmux bash-completion \
        ccache less ffmpeg yt-dlp noto-fonts{,-cjk,-emoji,-extra} otf-ipaexfont wqy-microhei \
        gamemode mold amdgpu_top htop tree clang kdeconnect zstd pigz pbzip2 plzip kimageformats \
        docker docker-compose kolourpaint kate steam tmux protonup-qt-bin protontricks cmake \
        || echo warn: there are errors in this stage, please review it
else
    printf "##########################################\n"
    printf "# paru is not available. skipping.       #\n"
    printf "# install paru and run this script again #\n"
    printf "##########################################\n"
fi
echo 'done'

echo '==' installing the chromium policy
sudo mkdir -p /etc/chromium/policies/managed/
sudo tee /etc/chromium/policies/managed/meine.json > /dev/null << 'EOF'
{
    "AutoFillEnabled": false,
    "AutofillCreditCardEnabled": false,
    "AutofillAddressEnabled": false,
    "PasswordManagerEnabled": false,
    "DnsOverHttpsMode": "secure",
    "DnsOverHttpsTemplates": "https://cloudflare-dns.com/dns-query",
    "DefaultSearchProviderEnabled": true,
    "DefaultSearchProviderName": "DuckDuckGo",
    "DefaultSearchProviderEncodings": ["UTF-8"],
    "DefaultSearchProviderSearchURL": "https://duckduckgo.com/?q={searchTerms}",
    "DefaultSearchProviderSuggestURL":"https://duckduckgo.com/ac/?q={searchTerms}&type=list",
    "MetricsReportingEnabled": false,
    "NetworkPredictionOptions": 2,
    "PaymentMethodQueryEnabled": false,
    "PrivacySandboxAdMeasurementEnabled": false,
    "PrivacySandboxAdTopicsEnabled": false,
    "PrivacySandboxPromptEnabled": false,
    "PrivacySandboxSiteEnabledAdsEnabled": false,
    "HighEfficiencyModeEnabled": true,
    "MemorySaverModeSavings": 0,
    "SpellcheckEnabled": false,
    "NewTabPageLocation": "data:text/html;base64,PHN0eWxlPmJvZHkgeyBiYWNrZ3JvdW5kOiBsaW5lYXItZ3JhZGllbnQoMTMzZGVnLHJnYmEoNDIs IDgsIDk2LCAxKSAwJSwgcmdiYSgxNSwgMSwgNDAsIDEpIDEwMCUpO308L3N0eWxlPg==",
    "HomepageIsNewTabPage": true,
    "ShowHomeButton": false,
    "SiteSearchSettings": [
        {
            "name": "Jisho",
            "shortcut": "jisho",
            "url": "https://jisho.org/search/{searchTerms}",
            "allow_user_override": false
        },
        {
            "name": "Tureng",
            "shortcut": "tureng",
            "url": "https://tureng.com/en/turkish-english/{searchTerms}",
            "allow_user_override": false
        }
    ]
}
EOF
echo 'done'

echo '==' installing templated files
cp -i .config/FreeTube/settings_template.db .config/FreeTube/settings.db || echo skipped
cp -i .config/qView/qView_template.conf .config/qView/qView.conf || echo skipped
cp -i .local/share/PrismLauncher/prismlauncher_template.cfg .local/share/PrismLauncher/prismlauncher.cfg || echo skipped
echo 'done'

echo '==' configuring misc plasma stuff
# --- kdeglobals ---
kwriteconfig6 --file kdeglobals --group "General" --key "TerminalApplication" "alacritty"
kwriteconfig6 --file kdeglobals --group "KDE" --key "AutomaticLookAndFeel" "true"
kwriteconfig6 --file kdeglobals --group "KDE" --key "LookAndFeelPackage" "org.kde.breeze.desktop"
kwriteconfig6 --file kdeglobals --group "KDE" --key "NightLookAndFeelPackage" "org.kde.breezedark.desktop"

# --- dolphinrc ---
kwriteconfig6 --file dolphinrc --group "DetailsMode" --key "LeftPadding" "10"
kwriteconfig6 --file dolphinrc --group "DetailsMode" --key "PreviewSize" "16"
kwriteconfig6 --file dolphinrc --group "DetailsMode" --key "RightPadding" "55"
kwriteconfig6 --file dolphinrc --group "KFileDialog Settings" --key "Places Icons Auto-resize" "false"
kwriteconfig6 --file dolphinrc --group "KFileDialog Settings" --key "Places Icons Static Size" "16"
kwriteconfig6 --file dolphinrc --group "MainWindow" --key "MenuBar" "Disabled"
kwriteconfig6 --file dolphinrc --group "PlacesPanel" --key "IconSize" "16"

# --- kolourpaintrc ---
kwriteconfig6 --file kolourpaintrc --group "MainWindow" --group "Toolbar Tool Box" --key "ToolButtonStyle" "IconOnly"
kwriteconfig6 --file kolourpaintrc --group "MainWindow" --group "Toolbar Tool Box" --key "IconSize" "16"
kwriteconfig6 --file kolourpaintrc --group "MainWindow" --group "Toolbar mainToolBar" --key "ToolButtonStyle" "IconOnly"
kwriteconfig6 --file kolourpaintrc --group "MainWindow" --group "Toolbar mainToolBar" --key "IconSize" "16"

# --- kwriterc ---
kwriteconfig6 --file kwriterc --group "General" --key "Tab Double Click New Document" "false"
kwriteconfig6 --file kwriterc --group "General" --key "Tab Middle Click Close Document" "false"
kwriteconfig6 --file kwriterc --group "KTextEditor Renderer" --key "Text Font" "IBM Plex Mono,11,-1,5,500,0,0,0,0,0,0,0,0,0,0,1,Medium,0,0"

# --- kwalletrc ---
kwriteconfig6 --file kwalletrc --group "Wallet" --key "Enabled" "false" # fuck you kwallet

# --- spectaclerc ---
kwriteconfig6 --file spectaclerc --group "General" --key "ocrLanguages" "tur,eng,jpn"
kwriteconfig6 --file spectaclerc --group "General" --key "rememberSelectionRect" "Never"
kwriteconfig6 --file spectaclerc --group "GuiConfig" --key "quitAfterSaveCopyExport" "true"
echo 'done'

echo '==' installing vscode extensions
VSCODE_EXTS=(
    "llvm-vs-code-extensions.vscode-clangd"
    "ms-python.debugpy"
    "ms-python.python"
    "ms-python.vscode-python-envs"
    "nonoroazoro.syncing"
    "rust-lang.rust-analyzer"
)
VSCODE_EXEC=codium

if "$VSCODE_EXEC" --version &> /dev/null; then
    for ext in "${VSCODE_EXTS[@]}"; do
        NODE_OPTIONS="--no-deprecation" $VSCODE_EXEC --install-extension "$ext" --force
    done
else
    echo warn: "$VSCODE_EXEC" is not installed, skipping
fi
echo 'done'
