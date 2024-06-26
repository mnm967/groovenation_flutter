import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// How much the scroll's drag gesture can overshoot the RefreshIndicator's
// displacement; max displacement = _kDragSizeFactorLimit * displacement.
const double _kDragSizeFactorLimit = 1.5;

/// mostly use flutter inner's RefreshIndicator
class CustomMaterialClassicHeader extends RefreshIndicator {
  /// see flutter RefreshIndicator documents,the meaning same with that
  final String? semanticsLabel;

  /// see flutter RefreshIndicator documents,the meaning same with that
  final String? semanticsValue;

  /// see flutter RefreshIndicator documents,the meaning same with that
  final Color? color;

  /// Distance from the top when refreshing
  final double distance;

  /// see flutter RefreshIndicator documents,the meaning same with that
  final Color? backgroundColor;

  const CustomMaterialClassicHeader({
    Key? key,
    double height: 80.0,
    this.semanticsLabel,
    this.semanticsValue,
    this.color,
    double offset: 0,
    this.distance: 50.0,
    this.backgroundColor,
  }) : super(
          key: key,
          refreshStyle: RefreshStyle.UnFollow,
          offset: offset,
          height: height,
        );

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return _MaterialClassicHeaderState();
  }
}

class _MaterialClassicHeaderState
    extends RefreshIndicatorState<CustomMaterialClassicHeader>
    with TickerProviderStateMixin {
  ScrollPosition? _position;
  Animation<Offset>? _positionFactor;
  Animation<Color?>? _valueColor;
  late AnimationController _scaleFactor;
  late AnimationController _positionController;
  late AnimationController _valueAni;

  @override
  void initState() {
    super.initState();
    _valueAni = AnimationController(
        vsync: this,
        value: 0.0,
        lowerBound: 0.0,
        upperBound: 1.0,
        duration: Duration(milliseconds: 500));
    _valueAni.addListener(() {
      // frequently setState will decline the performance
      if (mounted && _position!.pixels <= 0) setState(() {});
    });
    _positionController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _scaleFactor = AnimationController(
        vsync: this,
        value: 1.0,
        lowerBound: 0.0,
        upperBound: 1.0,
        duration: Duration(milliseconds: 300));
    _positionFactor = _positionController.drive(Tween<Offset>(
        begin: Offset(0.0, -1.0), end: Offset(0.0, widget.height / 44.0)));
  }

  @override
  void didUpdateWidget(covariant CustomMaterialClassicHeader oldWidget) {
    _position = Scrollable.of(context)!.position;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    return _buildIndicator(widget.backgroundColor ?? Colors.white);
  }

  Widget _buildIndicator(Color outerColor) {
    return SlideTransition(
      child: ScaleTransition(
        scale: _scaleFactor,
        child: Align(
          alignment: Alignment.topCenter,
          child: RefreshProgressIndicator(
            semanticsLabel: widget.semanticsLabel ??
                MaterialLocalizations?.of(context)
                    .refreshIndicatorSemanticLabel,
            semanticsValue: widget.semanticsValue,
            value: floating ? null : _valueAni.value,
            valueColor: _valueColor,
            backgroundColor: outerColor,
          ),
        ),
      ),
      position: _positionFactor!,
    );
  }

  @override
  void onOffsetChange(double offset) {
    if (!floating) {
      _valueAni.value = offset / configuration!.headerTriggerDistance;
      _positionController.value = offset / configuration!.headerTriggerDistance;
    }
  }

  @override
  void onModeChange(RefreshStatus? mode) {
    if (mode == RefreshStatus.refreshing) {
      _positionController.value = widget.distance / widget.height;
      _scaleFactor.value = 1;
    }
    super.onModeChange(mode);
  }

  @override
  void resetValue() {
    _scaleFactor.value = 1.0;
    _positionController.value = 0.0;
    _valueAni.value = 0.0;
    super.resetValue();
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _position = Scrollable.of(context)!.position;
    _valueColor = _positionController.drive(
      ColorTween(
        begin: (widget.color ?? theme.primaryColor).withOpacity(0.0),
        end: (widget.color ?? theme.primaryColor).withOpacity(1.0),
      ).chain(
          CurveTween(curve: const Interval(0.0, 1.0 / _kDragSizeFactorLimit))),
    );
    super.didChangeDependencies();
  }

  @override
  Future<void> readyToRefresh() {
    return _positionController.animateTo(widget.distance / widget.height);
  }

  @override
  Future<void> endRefresh() {
    return _scaleFactor.animateTo(0.0);
  }

  @override
  void dispose() {
    _valueAni.dispose();
    _scaleFactor.dispose();
    _positionController.dispose();
    super.dispose();
  }
}