import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../state_container.dart';
import 'menu_btn.dart';

PlatformAppBar buildAppBar(
    {required BuildContext context, required Function setState}) {
  final container = StateContainer.of(context)!;

  List<Widget> actions = <Widget>[
    PlatformIconButton(
      icon: Icon(context.platformIcons.leftChevron),
      material: (context, target) => MaterialIconButtonData(
        tooltip: 'Retroceder día',
      ),
      onPressed: container.decrementDate,
    ),
    TodayButton(
      onPressed: container.today,
    ),
    PlatformIconButton(
      icon: Icon(context.platformIcons.rightChevron),
      material: (context, target) => MaterialIconButtonData(
        tooltip: 'Avanzar día',
      ),
      onPressed: container.incrementDate,
    ),
    Material(child: MenuBtn()),
  ];

  return PlatformAppBar(
    backgroundColor: Theme.of(context).canvasColor,
    leading: Center(
      child: Text(
        container.title ?? 'Menú Chapingo',
        overflow: TextOverflow.fade,
      ),
    ),
    cupertino: (context, target) => CupertinoNavigationBarData(
      border: Border(),
    ),
    material: (context, platform) => MaterialAppBarData(
      bottom: const TabBar(
        isScrollable: true,
        tabs: <Widget>[
          Tab(text: 'DESAYUNO'),
          Tab(text: 'COMIDA'),
          Tab(text: 'CENA'),
        ],
      ),
    ),
    trailingActions: actions,
  );
}

class TodayButton extends StatelessWidget {
  const TodayButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: Platform.isIOS
          ? CupertinoColors.systemBlue
          : Theme.of(context).iconTheme.color,
      icon: Stack(
        children: <Widget>[
          Container(
              alignment: Alignment.center,
              margin: EdgeInsets.zero,
              padding:
                  EdgeInsets.fromLTRB(0.4, Platform.isIOS ? 10 : 5.5, 0.0, 0.0),
              child: Text(
                DateTime.now().day.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11.0,
                  color: onPressed != null
                      ? (Platform.isIOS
                          ? CupertinoColors.systemBlue
                          : Theme.of(context).appBarTheme.foregroundColor)
                      : Theme.of(context).disabledColor,
                ),
                textScaleFactor: 1.0,
              )),
          Container(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
            child: const Icon(Icons.calendar_today),
          ),
        ],
      ),
      tooltip: 'Hoy',
      onPressed: onPressed,
    );
  }
}
