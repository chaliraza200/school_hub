import 'package:flutter/widgets.dart';

class AppRadius {
  const AppRadius._();

  static const double smValue = 6.0;
  static const double mdValue = 10.0;
  static const double lgValue = 14.0;
  static const double fullValue = 999.0;

  static const Radius sm = Radius.circular(smValue);
  static const Radius md = Radius.circular(mdValue);
  static const Radius lg = Radius.circular(lgValue);
  static const Radius full = Radius.circular(fullValue);

  static final BorderRadius borderRadiusSm = BorderRadius.circular(smValue);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(mdValue);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(lgValue);
  static final BorderRadius borderRadiusFull = BorderRadius.circular(fullValue);
}