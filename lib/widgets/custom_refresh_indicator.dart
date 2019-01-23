import 'package:flutter/material.dart';
import 'package:menu2018/state_container.dart';

class CustomRefreshIndicator extends StatelessWidget {
  const CustomRefreshIndicator({@required this.child, this.isTopLevel = false});

  final Widget child;
  final bool isTopLevel;

  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    return RefreshIndicator(
      child: child,
      onRefresh: container.update(context),
      key: isTopLevel ? container.refreshIndicatorKey : null,
    );
  }
}