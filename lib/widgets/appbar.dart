import 'package:flutter/material.dart';
import 'package:menu2018/state_container.dart';
import 'menu_btn.dart';

AppBar buildAppBar({BuildContext context, Function setState}) {
  final container = StateContainer.of(context);
  return AppBar(
    title: Text(
      container.title,
      overflow: TextOverflow.fade,
    ),
    bottom: const TabBar(
      isScrollable: true,
      tabs: <Widget>[
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
      MenuBtn(),
    ],
  );
}

class TodayButton extends StatelessWidget {
  const TodayButton({
    Key key,
    this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        children: <Widget>[
          Container(
              child: Text(
                DateTime.now().day.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11.0,
                  color: onPressed != null
                      ? Colors.white
                      : Theme.of(context).disabledColor,
                ),
                textScaleFactor: 1.0,
              ),
              alignment: Alignment.center,
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.fromLTRB(0.4, 5.5, 0.0, 0.0)),
          Container(
            child: const Icon(Icons.calendar_today),
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
          ),
        ],
      ),
      tooltip: 'Hoy',
      onPressed: onPressed,
    );
  }
}
