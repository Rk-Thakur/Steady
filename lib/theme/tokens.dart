import 'package:flutter/material.dart';

/// Steady design tokens (Handoff 1 · Tokens & layout, Dark tokens board).
/// Reference tokens by name in widgets; never hard-code hex values there.

/// Spacing on a 4pt grid: space-1 … space-8.
abstract final class SteadySpace {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s7 = 32;
  static const double s8 = 48;

  /// Left/right screen margin.
  static const double screenMargin = s5;

  /// Gap between blocks on a screen.
  static const double sectionGap = 18;
}

abstract final class SteadyRadius {
  /// Chips.
  static const double sm = 8;

  /// Inputs, icon tiles.
  static const double md = 14;

  /// Cards.
  static const double lg = 20;

  /// Hero card, tab bar.
  static const double xl = 24;

  /// Buttons, chips, segmented controls, bars.
  static const double pill = 999;
}

abstract final class SteadySize {
  /// Smallest tappable area: Android's 48dp (also covers iOS's 44pt).
  static const double minTouchTarget = 48;
  static const double buttonLarge = 52;
  static const double buttonCompact = 44;
  static const double iconButton = 44;
  static const double iconTile = 40;
  static const double tabBarHeight = 72;
  static const double tabBarInset = 12;
  static const double tabBarBottom = 16;
  static const double fab = 52;

  /// Distance from the screen's bottom edge to the floating tab bar.
  /// On phones with a home indicator the bar sits just above the indicator
  /// (inside the safe area) instead of a full 16 above it.
  static double tabBarOffset(EdgeInsets safe) =>
      safe.bottom > 0 ? (safe.bottom - 14).clamp(8.0, 40.0) : tabBarBottom;

  /// Bottom padding so scrolling content clears the tab bar by 16.
  static double tabBarClearance(EdgeInsets safe) =>
      tabBarOffset(safe) + tabBarHeight + SteadySpace.s4;
}

abstract final class SteadyMotion {
  static const heroNumber = Duration(milliseconds: 400);
  static const progress = Duration(milliseconds: 600);
  static const screen = Duration(milliseconds: 280);
  static const sheet = Duration(milliseconds: 320);

  /// Used for everything when the OS "reduce motion" setting is on.
  static const reduced = Duration(milliseconds: 150);

  static const progressCurve = Cubic(.2, .8, .2, 1);
  static const sheetCurve = Cubic(.2, .9, .3, 1);
}

abstract final class SteadyFonts {
  /// Amounts and titles.
  static const display = 'BricolageGrotesque';

  /// Everything else.
  static const body = 'Manrope';

  static const tabular = [FontFeature.tabularFigures()];

  /// Bricolage Grotesque's optical-size axis. Browsers set it from the font
  /// size automatically; Flutter does not, so display styles set it explicitly.
  /// (Weight needs no variation: fontWeight drives the wght axis.)
  static List<FontVariation> opticalSize(double size) => [
    FontVariation('opsz', size.clamp(12, 96)),
  ];
}

/// Color tokens. Light values from Handoff 1, dark values from the Dark tokens board.
@immutable
class SteadyColors extends ThemeExtension<SteadyColors> {
  const SteadyColors({
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.highlight,
    required this.onHighlight,
    required this.ink,
    required this.muted,
    required this.ground,
    required this.surface,
    required this.raised,
    required this.line,
    required this.lineSoft,
    required this.inputBorder,
    required this.disabledBg,
    required this.disabledFg,
    required this.positive,
    required this.warningFg,
    required this.warningBg,
    required this.dangerFg,
    required this.dangerBg,
    required this.infoFg,
    required this.infoBg,
    required this.hero,
    required this.onHero,
    required this.onHeroMuted,
    required this.heroTrack,
    required this.billPaid,
    required this.billPending,
    required this.fab,
    required this.onFab,
    required this.tabActive,
    required this.segmentTrack,
    required this.segmentSelected,
    required this.progressTrack,
    required this.chartOver,
    required this.dashed,
    required this.mutedStrong,
    required this.inverse,
    required this.onInverse,
    required this.onInverseMuted,
    required this.skeleton,
    required this.heroSkeleton,
  });

  /// color-primary: primary buttons, active tab, links. In dark this is Signal.
  final Color primary;
  final Color onPrimary;

  /// color-primary-soft: selected chips, success/info cards.
  final Color primarySoft;

  /// color-highlight: ONE key action per screen, always with [onHighlight] text.
  final Color highlight;
  final Color onHighlight;

  /// color-ink: body text, secondary borders.
  final Color ink;

  /// color-muted: secondary text, 13px minimum.
  final Color muted;

  /// color-ground: screen background.
  final Color ground;

  /// color-surface: cards, tab bar.
  final Color surface;

  /// Inputs and sheets (dark elevation = lighter surface, not shadow).
  final Color raised;

  /// color-line: card borders and dividers.
  final Color line;

  /// Dividers inside cards.
  final Color lineSoft;
  final Color inputBorder;
  final Color disabledBg;
  final Color disabledFg;

  /// "Safe" / positive money state.
  final Color positive;

  final Color warningFg;
  final Color warningBg;
  final Color dangerFg;
  final Color dangerBg;
  final Color infoFg;
  final Color infoBg;

  /// The Today hero card stays Pine in both themes.
  final Color hero;
  final Color onHero;
  final Color onHeroMuted;
  final Color heroTrack;

  final Color billPaid;
  final Color billPending;

  final Color fab;
  final Color onFab;
  final Color tabActive;

  /// Track behind segmented controls.
  final Color segmentTrack;

  /// Selected item in a segmented control.
  final Color segmentSelected;

  /// Empty part of progress bars in cards.
  final Color progressTrack;

  /// Chart bars that went over the daily number.
  final Color chartOver;

  /// Dashed outlines: add-chips, empty and estimate states.
  final Color dashed;

  /// Secondary text on soft (primarySoft) fills.
  final Color mutedStrong;

  /// Dark feature cards (Vault, Splits, toasts).
  final Color inverse;

  /// Text on [inverse].
  final Color onInverse;

  /// Secondary text on [inverse].
  final Color onInverseMuted;

  /// Loading placeholders.
  final Color skeleton;

  /// Loading placeholders inside the hero card.
  final Color heroSkeleton;

  static const light = SteadyColors(
    primary: Color(0xFF1F5A47),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFDCEAE3),
    highlight: Color(0xFFC9F26B),
    onHighlight: Color(0xFF12201B),
    ink: Color(0xFF12201B),
    muted: Color(0xFF56645E),
    ground: Color(0xFFF1F4F0),
    surface: Color(0xFFFFFFFF),
    raised: Color(0xFFFFFFFF),
    line: Color(0xFFDDE3DE),
    lineSoft: Color(0xFFEDF0EE),
    inputBorder: Color(0xFFC7D0CA),
    disabledBg: Color(0xFFDDE3DE),
    disabledFg: Color(0xFF6B7772),
    positive: Color(0xFF1F5A47),
    warningFg: Color(0xFF9A4A06),
    warningBg: Color(0xFFFCEBD2),
    dangerFg: Color(0xFFB42318),
    dangerBg: Color(0xFFFBE3E0),
    infoFg: Color(0xFF2459C9),
    infoBg: Color(0xFFE1E9FB),
    hero: Color(0xFF1F5A47),
    onHero: Color(0xFFFFFFFF),
    onHeroMuted: Color(0xFFD6E7DF),
    heroTrack: Color(0x2EFFFFFF),
    billPaid: Color(0xFF1F5A47),
    billPending: Color(0xFF8FB5A6),
    fab: Color(0xFF12201B),
    onFab: Color(0xFFC9F26B),
    tabActive: Color(0xFF1F5A47),
    segmentTrack: Color(0xFFE3E8E4),
    segmentSelected: Color(0xFFFFFFFF),
    progressTrack: Color(0xFFE6EBE7),
    chartOver: Color(0xFFE08A2E),
    dashed: Color(0xFF8FB5A6),
    mutedStrong: Color(0xFF3E4C46),
    inverse: Color(0xFF12201B),
    onInverse: Color(0xFFFFFFFF),
    onInverseMuted: Color(0xFFC9D4CE),
    skeleton: Color(0xFFE3E8E4),
    heroSkeleton: Color(0xFF2F6E59),
  );

  static const dark = SteadyColors(
    primary: Color(0xFFC9F26B),
    onPrimary: Color(0xFF12201B),
    // Not specified on the Dark tokens board; a Pine tint on Raised.
    primarySoft: Color(0xFF1F3A30),
    highlight: Color(0xFFC9F26B),
    onHighlight: Color(0xFF12201B),
    ink: Color(0xFFEEF3EF),
    muted: Color(0xFF9FB0A8),
    ground: Color(0xFF0E1714),
    surface: Color(0xFF17231F),
    raised: Color(0xFF1F2E29),
    line: Color(0xFF2B3B35),
    lineSoft: Color(0xFF2B3B35),
    inputBorder: Color(0xFF2B3B35),
    disabledBg: Color(0xFF2B3B35),
    disabledFg: Color(0xFF9FB0A8),
    positive: Color(0xFF7FD8AE),
    warningFg: Color(0xFFF2B45C),
    warningBg: Color(0xFF3A2A12),
    dangerFg: Color(0xFFFF8A7A),
    dangerBg: Color(0xFF3B1A17),
    infoFg: Color(0xFF8FB1FF),
    infoBg: Color(0xFF18233F),
    hero: Color(0xFF1F5A47),
    onHero: Color(0xFFFFFFFF),
    onHeroMuted: Color(0xFFD6E7DF),
    heroTrack: Color(0x2EFFFFFF),
    billPaid: Color(0xFF7FD8AE),
    billPending: Color(0xFF2B3B35),
    fab: Color(0xFFC9F26B),
    onFab: Color(0xFF12201B),
    tabActive: Color(0xFFC9F26B),
    segmentTrack: Color(0xFF17231F),
    segmentSelected: Color(0xFF2B3B35),
    progressTrack: Color(0xFF2B3B35),
    chartOver: Color(0xFFF2B45C),
    dashed: Color(0xFF3F5A50),
    mutedStrong: Color(0xFFC9D4CE),
    inverse: Color(0xFF1F2E29),
    onInverse: Color(0xFFEEF3EF),
    onInverseMuted: Color(0xFF9FB0A8),
    skeleton: Color(0xFF1F2E29),
    heroSkeleton: Color(0xFF2F6E59),
  );

  @override
  SteadyColors copyWith() => this;

  @override
  SteadyColors lerp(SteadyColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return SteadyColors(
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      primarySoft: l(primarySoft, other.primarySoft),
      highlight: l(highlight, other.highlight),
      onHighlight: l(onHighlight, other.onHighlight),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      ground: l(ground, other.ground),
      surface: l(surface, other.surface),
      raised: l(raised, other.raised),
      line: l(line, other.line),
      lineSoft: l(lineSoft, other.lineSoft),
      inputBorder: l(inputBorder, other.inputBorder),
      disabledBg: l(disabledBg, other.disabledBg),
      disabledFg: l(disabledFg, other.disabledFg),
      positive: l(positive, other.positive),
      warningFg: l(warningFg, other.warningFg),
      warningBg: l(warningBg, other.warningBg),
      dangerFg: l(dangerFg, other.dangerFg),
      dangerBg: l(dangerBg, other.dangerBg),
      infoFg: l(infoFg, other.infoFg),
      infoBg: l(infoBg, other.infoBg),
      hero: l(hero, other.hero),
      onHero: l(onHero, other.onHero),
      onHeroMuted: l(onHeroMuted, other.onHeroMuted),
      heroTrack: l(heroTrack, other.heroTrack),
      billPaid: l(billPaid, other.billPaid),
      billPending: l(billPending, other.billPending),
      fab: l(fab, other.fab),
      onFab: l(onFab, other.onFab),
      tabActive: l(tabActive, other.tabActive),
      segmentTrack: l(segmentTrack, other.segmentTrack),
      segmentSelected: l(segmentSelected, other.segmentSelected),
      progressTrack: l(progressTrack, other.progressTrack),
      chartOver: l(chartOver, other.chartOver),
      dashed: l(dashed, other.dashed),
      mutedStrong: l(mutedStrong, other.mutedStrong),
      inverse: l(inverse, other.inverse),
      onInverse: l(onInverse, other.onInverse),
      onInverseMuted: l(onInverseMuted, other.onInverseMuted),
      skeleton: l(skeleton, other.skeleton),
      heroSkeleton: l(heroSkeleton, other.heroSkeleton),
    );
  }
}

/// Type tokens (Handoff 1). Numbers are always tabular.
abstract final class SteadyType {
  /// font-amount-xl: hero money figure. Shrinks to 48 at 360 wide.
  static const amountXl = TextStyle(
    fontFamily: SteadyFonts.display,
    fontSize: 56,
    height: 1.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    fontFeatures: SteadyFonts.tabular,
    fontVariations: [FontVariation('opsz', 56)],
  );

  /// font-title: screen titles.
  static const title = TextStyle(
    fontFamily: SteadyFonts.display,
    fontSize: 26,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    fontFeatures: SteadyFonts.tabular,
    fontVariations: [FontVariation('opsz', 26)],
  );

  /// font-heading: section and card titles.
  static const heading = TextStyle(
    fontFamily: SteadyFonts.body,
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w700,
    fontFeatures: SteadyFonts.tabular,
  );

  /// font-body: body, list rows.
  static const body = TextStyle(
    fontFamily: SteadyFonts.body,
    fontSize: 15,
    height: 1.45,
    fontWeight: FontWeight.w500,
    fontFeatures: SteadyFonts.tabular,
  );

  /// font-caption: meta, helper text.
  static const caption = TextStyle(
    fontFamily: SteadyFonts.body,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w600,
    fontFeatures: SteadyFonts.tabular,
  );

  /// font-overline: group labels (render in caps).
  static const overline = TextStyle(
    fontFamily: SteadyFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
    fontFeatures: SteadyFonts.tabular,
  );

  /// Button labels.
  static const button = TextStyle(
    fontFamily: SteadyFonts.body,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  /// Tab bar labels.
  static const tab = TextStyle(
    fontFamily: SteadyFonts.body,
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );
}

extension SteadyThemeX on BuildContext {
  SteadyColors get colors => Theme.of(this).extension<SteadyColors>()!;
}
