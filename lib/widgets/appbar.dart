import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:menu2018/models/settings.dart';
import 'package:provider/provider.dart';
import '../state_container.dart';
import 'menu_btn.dart';

AppBar buildAppBar(
    {required BuildContext context, required Function setState}) {
  final container = StateContainer.of(context);

  return AppBar(
    title: Text(
      container.title,
      overflow: TextOverflow.fade,
    ),
    bottom: TabBar(
      isScrollable: true,
      labelColor: Provider.of<Settings>(context).isIOSTheme()
          ? CupertinoColors.activeBlue
          : null,
      tabs: const <Widget>[
        Tab(text: 'DESAYUNO'),
        Tab(text: 'COMIDA'),
        Tab(text: 'CENA'),
      ],
    ),
    actions: <Widget>[
      IconButton(
        icon: const Icon(Icons.chevron_left),
        tooltip: 'Retroceder día',
        onPressed: container.decrementDate,
      ),
      TodayButton(
        onPressed: container.today,
      ),
      IconButton(
        icon: const Icon(Icons.chevron_right),
        tooltip: 'Avanzar día',
        onPressed: container.incrementDate,
      ),
      const MenuBtn(),
    ],
  );
}

class TodayButton extends StatelessWidget {
  const TodayButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final preMaterial3Padding = const EdgeInsets.fromLTRB(0.4, 5.5, 0.0, 0.0);
  final material3Padding = const EdgeInsets.fromLTRB(8.5, 5.5, 0.0, 0.0);

  @override
  Widget build(BuildContext context) {
    // why??? is there a better way?
    final padding =
        Theme.of(context).useMaterial3 ? material3Padding : preMaterial3Padding;
    return IconButton(
      icon: Stack(
        children: <Widget>[
          Container(
              alignment: Alignment.center,
              margin: EdgeInsets.zero,
              padding: padding,
              child: Text(
                DateTime.now().day.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11.0,
                  color: onPressed != null
                      ? Theme.of(context).appBarTheme.actionsIconTheme?.color
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
