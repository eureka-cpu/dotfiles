# Vendored build of ompweb (https://github.com/kahme247/ompweb).
#
# Upstream's own `nix/package.nix` lists `next-env.d.ts` in its source fileset,
# but that file is gitignored upstream, so `inputs.ompweb.packages.default`
# (and `nix run github:kahme247/ompweb`) fail to *evaluate* for any consumer.
# This is a copy of that package with the missing entry dropped from the
# fileset — `next build` regenerates `next-env.d.ts` during the build phase —
# and the Node version pinned to match the package's `engines` (>= 24).
#
# `source` is the ompweb flake input (its source tree). `kasaneColors`, when
# set to a kasane palette (`programs.kasane.colors`), adds a "Kasane" theme
# built from it and makes it the default; see `kasaneTheme` below.
{
  lib,
  buildNpmPackage,
  fetchurl,
  writeText,
  nodejs_24,
  source,
  kasaneColors ? null,
}:
let
  notoSansMono = fetchurl {
    name = "NotoSansMono.ttf";
    url = "https://raw.githubusercontent.com/notofonts/notofonts.github.io/noto-monthly-release-2026.08.01/fonts/NotoSansMono/unhinted/variable-ttf/NotoSansMono%5Bwdth%2Cwght%5D.ttf";
    hash = "sha256-BLG//8WYEU+ZjGDzE/emTfbJEez+1Hok4n8Dsd80v2Y=";
  };

  sourceSerif = fetchurl {
    name = "SourceSerif4Variable-Roman.otf";
    url = "https://raw.githubusercontent.com/adobe-fonts/source-serif/4.005R/VAR/SourceSerif4Variable-Roman.otf";
    hash = "sha256-hntzxqlUpKZGFpBtF5+UVyp0h5Ch0CLr7v8H9W6gIho=";
  };

  jetBrainsMono = fetchurl {
    name = "JetBrainsMono.ttf";
    url = "https://raw.githubusercontent.com/JetBrains/JetBrainsMono/v2.304/fonts/variable/JetBrainsMono%5Bwght%5D.ttf";
    hash = "sha256-ZioZbVjxGDvy13QottUoP+P0UWGrAhvqQDa8mOXKwBY=";
  };

  geist = fetchurl {
    name = "Geist.ttf";
    url = "https://raw.githubusercontent.com/vercel/geist-font/v1.7.2/fonts/Geist/variable/Geist%5Bwght%5D.ttf";
    hash = "sha256-c4lOBEjK6QqStsL4cyt7uay3uUxBi/9Vna1KGOHellk=";
  };

  localFontsPatch = writeText "ompweb-local-fonts.patch" ''
    diff --git a/app/layout.tsx b/app/layout.tsx
    --- a/app/layout.tsx
    +++ b/app/layout.tsx
    @@ -1,28 +1,30 @@
     import type { Metadata, Viewport } from "next";
     import { headers } from "next/headers";
     import Script from "next/script";
    -import { Geist, JetBrains_Mono, Noto_Sans_Mono, Source_Serif_4 } from "next/font/google";
    +import localFont from "next/font/local";
     import { ThemeColor } from "@/hooks/useTheme";
     import { IosFocusZoomGuard } from "@/components/IosFocusZoomGuard";
     import { SIDEBAR_HISTORY_BRIDGE_SCRIPT } from "@/lib/sidebar-history-bridge";
     import { getInstallName } from "@/lib/install-name";
     import "./globals.css";

    -const geist = Geist({
    -  subsets: ["latin"],
    +const geist = localFont({
    +  src: "./fonts/Geist.ttf",
    +  weight: "100 900",
       variable: "--font-geist",
       display: "swap",
     });

    -const jetbrainsMono = JetBrains_Mono({
    -  subsets: ["latin"],
    -  weight: ["400", "500", "600"],
    +const jetbrainsMono = localFont({
    +  src: "./fonts/JetBrainsMono.ttf",
    +  weight: "100 800",
       variable: "--font-jb-mono",
       display: "swap",
     });

    -const notoSansMono = Noto_Sans_Mono({
    -  subsets: ["latin", "cyrillic"],
    +const notoSansMono = localFont({
    +  src: "./fonts/NotoSansMono.ttf",
    +  weight: "100 900",
       variable: "--font-noto-mono",
       display: "swap",
     });
    @@ -31,8 +33,9 @@
     // latin; CJK uses a bundled Noto Serif SC subset declared in globals.css, not
     // next/font/google: Google Fonts sometimes serves it through extensionless
     // `/l/font?kit=` URLs that next/font cannot parse, which failed builds at random.
    -const sourceSerif = Source_Serif_4({
    -  subsets: ["latin"],
    +const sourceSerif = localFont({
    +  src: "./fonts/SourceSerif4Variable-Roman.otf",
    +  weight: "200 900",
       variable: "--font-source-serif",
       display: "swap",
     });
  '';

  # A "Kasane" entry in ompweb's theme list. Themes are CSS variable blocks in
  # app/globals.css plus a hardcoded list in hooks/useTheme.ts and the
  # pre-paint script in app/layout.tsx. Syntax colors are a JS object
  # (vsc-dark-plus), so its hex colors are rewritten to
  # `var(--syn-<hex>, <hex>)`: unchanged in every other theme, remapped here
  # to the same tokens kasane's helix themes use. Code blocks get their own
  # `--code-bg` (falling back to upstream's mix) so they can sit below the
  # page background like omp's tool blocks.
  kasaneTheme =
    let
      c = kasaneColors;
      css = writeText "ompweb-kasane.css" ''

        /* Kasane palette (generated from the host's programs.kasane.palette). */
        html[data-theme="kasane"], html.theme-kasane {
          color-scheme: dark;
          --bg: ${c.background};
          --bg-panel: ${c.black};
          --bg-hover: ${c.active_tab_background};
          --bg-selected: ${c.selection_background};
          --border: color-mix(in srgb, ${c.black-bright} 60%, ${c.background});
          --text: ${c.foreground};
          --text-muted: ${c.white-bright};
          --text-dim: ${c.white};
          --accent: ${c.yellow-bright};
          --accent-strong: ${c.yellow};
          --accent-hover: color-mix(in srgb, ${c.yellow-bright} 80%, white);
          --user-bg: ${c.active_tab_background};
          --tool-bg: ${c.black};
          --code-bg: ${c.black};
          --bg-subtle: color-mix(in srgb, ${c.foreground} 5%, transparent);
          --status-error: ${c.red-bright};
          --status-success: ${c.green-bright};
          --status-warning: ${c.yellow};
          --status-modified: ${c.magenta};
          --status-renamed: ${c.blue};
          --on-accent: ${c.background};
          --overlay-backdrop: color-mix(in srgb, var(--text) 24%, transparent);
          --shadow-card: 0 1px 2px rgba(0,0,0,0.45), 0 0 0 1px rgba(255,255,255,0.04);
          --shadow-pop: 0 2px 8px rgba(0,0,0,0.55), 0 0 0 1px rgba(255,255,255,0.05);
          --shadow-modal: 0 8px 32px rgba(0,0,0,0.65), 0 0 0 1px rgba(255,255,255,0.07);
          /* vsc-dark-plus color -> kasane token */
          --syn-d4d4d4: ${c.foreground};    /* text, punctuation, operators */
          --syn-9cdcfe: ${c.foreground};    /* variables, properties */
          --syn-569cd6: ${c.blue-bright};   /* keywords, booleans, tags */
          --syn-c586c0: ${c.blue-bright};   /* control-flow keywords */
          --syn-dcdcaa: ${c.yellow-bright}; /* functions */
          --syn-4ec9b0: ${c.blue};          /* types, classes */
          --syn-ce9178: ${c.green-bright};  /* strings */
          --syn-b5cea8: ${c.yellow};        /* numbers */
          --syn-6a9955: ${c.black-bright};  /* comments */
          --syn-808080: ${c.white};         /* markup punctuation */
          --syn-d7ba7d: ${c.cyan};          /* escapes, selectors */
          --syn-d16969: ${c.cyan-bright};   /* regex */
          --syn-db4c69: ${c.red-bright};
          --syn-264f78: ${c.selection_background}; /* selection */
        }
      '';
      codeBg = ''"color-mix(in srgb, var(--bg) 88%, var(--bg-panel))"'';
    in
    ''
      cat ${css} >> app/globals.css

      substituteInPlace hooks/useTheme.ts \
        --replace-fail '  | "tokyo-night";' '  | "tokyo-night"
        | "kasane";' \
        --replace-fail '  { id: "omp", name: "OMP Midnight"' '  { id: "kasane", name: "Kasane", mode: "dark", bg: "${c.background}", accent: "${c.yellow-bright}" },
        { id: "omp", name: "OMP Midnight"' \
        --replace-fail '  "tokyo-night": true,' '  "tokyo-night": true,
        kasane: true,' \
        --replace-fail 'if (typeof window === "undefined") return "omp";' 'if (typeof window === "undefined") return "kasane";' \
        --replace-fail '    return "omp";
        } catch {
          return "omp";' '    return "kasane";
        } catch {
          return "kasane";' \
        --replace-fail 'function getServerSnapshot(): ThemePreference {
        return "omp";' 'function getServerSnapshot(): ThemePreference {
        return "kasane";'

      substituteInPlace app/layout.tsx \
        --replace-fail '"tokyo-night":1}' '"tokyo-night":1,"kasane":1}' \
        --replace-fail '!t?"omp":t' '!t?"kasane":t'

      substituteInPlace components/SyntaxHighlightedCode.tsx \
        --replace-fail '${codeBg}' '"var(--code-bg, color-mix(in srgb, var(--bg) 88%, var(--bg-panel)))"'

      substituteInPlace lib/syntax-highlight.ts \
        --replace-fail 'const vscDarkPlus = withoutPreBackground(vscDarkPlusTheme);' '${''
          function withColorVars(theme: Record<string, CSSProperties>): Record<string, CSSProperties> {
            const toVar = (value: unknown) =>
              typeof value === "string" && /^#[0-9a-f]{3,6}$/i.test(value)
                ? `var(--syn-''${value.slice(1).toLowerCase()}, ''${value})`
                : value;
            return Object.fromEntries(
              Object.entries(theme).map(([selector, style]) => [
                selector,
                { ...style, color: toVar(style.color), background: toVar(style.background) } as CSSProperties,
              ]),
            );
          }
          const vscDarkPlus = withoutPreBackground(withColorVars(vscDarkPlusTheme));''}'
    '';

  # Upstream uses a lib.fileset here, but a flake input is a store path (a
  # string-like value fileset rejects) and already excludes gitignored paths
  # (node_modules, .next, next-env.d.ts). Use it directly as the source.
  src = source;
  version = (builtins.fromJSON (builtins.readFile (source + "/package.json"))).version;
in
buildNpmPackage (finalAttrs: {
  pname = "ompweb";
  inherit src version;

  nodejs = nodejs_24;

  patches = [ localFontsPatch ];

  postPatch = ''
    mkdir -p app/fonts
    cp ${notoSansMono} app/fonts/NotoSansMono.ttf
    cp ${sourceSerif} app/fonts/SourceSerif4Variable-Roman.otf
    cp ${jetBrainsMono} app/fonts/JetBrainsMono.ttf
    cp ${geist} app/fonts/Geist.ttf
  '' + lib.optionalString (kasaneColors != null) kasaneTheme;

  # Differs from upstream's hash because the build pins nodejs_24 (a different
  # npm version resolves the lockfile), not default nodejs.
  npmDepsHash = "sha256-sWlf6K96SKtjdaX5EWwoIT28r46QM17hd/o0qW8hSyY=";

  meta = {
    description = "Local web UI for the oh-my-pi (omp) coding agent";
    license = lib.licenses.mit;
    mainProgram = "ompweb";
  };
})
