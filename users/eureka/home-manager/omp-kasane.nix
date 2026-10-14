{ lib, config, ... }:
let
  # The host's kasane palette (programs.kasane.palette), keyed like kitty.
  # Token choices mirror kasane's helix themes so code reads the same in both.
  c = config.programs.kasane.colors;

  # Blend `amount` (0-100) of `fg` into `bg`: tinted backgrounds for tool
  # blocks, which the palette has no slots for.
  mix = amount: fg: bg:
    let
      channel = hex: i: lib.fromHexString (builtins.substring (1 + 2 * i) 2 hex);
      blend = i:
        lib.fixedWidthString 2 "0" (lib.toLower (lib.toHexString
          ((channel fg i * amount + channel bg i * (100 - amount)) / 100)));
    in
    "#${blend 0}${blend 1}${blend 2}";

  ground = c.background;
  raised = c.active_tab_background;
  paper = c.foreground;
  # Below the terminal background: sunken wells for tool and code output.
  sunken = c.black;
  nezumi = c.black-bright;

  theme = {
    name = "kasane";
    colors = {
      accent = c.yellow-bright;
      border = nezumi;
      borderAccent = c.yellow-bright;
      borderMuted = c.selection_background;
      success = c.green-bright;
      error = c.red-bright;
      warning = c.yellow;
      muted = c.white;
      dim = nezumi;
      text = paper;
      thinkingText = c.white;

      selectedBg = c.selection_background;
      userMessageBg = raised;
      userMessageText = paper;
      customMessageBg = sunken;
      customMessageText = paper;
      customMessageLabel = c.magenta;
      toolPendingBg = sunken;
      toolSuccessBg = sunken;
      toolErrorBg = mix 6 c.red sunken;
      toolTitle = paper;
      toolOutput = c.white;
      assistantMessageText = paper;

      mdHeading = c.green-bright;
      mdLink = c.magenta;
      mdLinkUrl = nezumi;
      mdCode = c.yellow-bright;
      mdCodeBlock = paper;
      mdCodeBlockBorder = nezumi;
      mdQuote = c.white;
      mdQuoteBorder = nezumi;
      mdHr = nezumi;
      mdListBullet = c.yellow-bright;

      toolDiffAdded = c.green-bright;
      toolDiffRemoved = c.red-bright;
      toolDiffContext = nezumi;

      syntaxComment = nezumi;
      syntaxKeyword = c.blue-bright;
      syntaxFunction = c.yellow-bright;
      syntaxVariable = paper;
      syntaxString = c.green-bright;
      syntaxNumber = c.yellow;
      syntaxType = c.blue;
      syntaxOperator = c.blue-bright;
      syntaxPunctuation = c.white;

      thinkingOff = nezumi;
      thinkingMinimal = c.white;
      thinkingLow = c.blue;
      thinkingMedium = c.cyan;
      thinkingHigh = c.magenta;
      thinkingXhigh = c.yellow;
      thinkingMax = c.red;
      bashMode = c.cyan-bright;
      pythonMode = c.magenta;

      statusLineBg = raised;
      statusLineSep = nezumi;
      statusLineModel = c.magenta;
      statusLinePath = c.blue-bright;
      statusLineGitClean = c.green-bright;
      statusLineGitDirty = c.yellow;
      statusLineContext = c.cyan-bright;
      statusLineSpend = c.cyan;
      statusLineStaged = c.green-bright;
      statusLineDirty = c.yellow;
      statusLineUntracked = c.red-bright;
      statusLineOutput = paper;
      statusLineCost = c.yellow-bright;
      statusLineSubagents = c.magenta;
    };
    export = {
      pageBg = ground;
      cardBg = raised;
      infoBg = c.selection_background;
    };
  };
in
{
  # omp custom theme generated from the active kasane palette; omp only reads
  # this file (and live-reloads it), so a store symlink is fine.
  home.file.".omp/agent/themes/kasane.json".text = builtins.toJSON theme;

  # kasane palettes are all dark, so only the dark slot follows them.
  programs.omp.settings.theme.dark = "kasane";
}
