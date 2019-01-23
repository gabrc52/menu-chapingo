import 'package:flutter/material.dart';
import 'package:menu2018/state_container.dart';
import 'package:menu2018/constants.dart';
import 'package:menu2018/widgets/custom_refresh_indicator.dart';
import 'package:menu2018/info.dart';

class TabContents extends StatelessWidget {
  const TabContents(this.alimento);

  final int alimento;

  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    container.firstRefresh();
    List<ListTile> getChildren(BuildContext context) {
      final List<String> menu = container.state.currentMenu(alimento);
      List<ListTile> children = []; // ignore: prefer_final_locals

      //Agregar info
      void addIfNotNull(Info info) {
        if (info.isNotNull) children.add(info.toListTile());
      }

      addIfNotNull(container.state.everydayInfo);
      addIfNotNull(container.state.currentInfo);

      //Agregar el menú
      var index = -1;
      for (var item in menu) {
        index++;
        if (item == null) continue;
        children.add((index == 2)
            ? ListTile(
                title: Text(
                  item,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            : ListTile(title: Text(item)));
      }
      return children;
    }

    try {
      return CustomRefreshIndicator(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          children: getChildren(context),
        ),
      );
    } on NoAlimentosException {
      return const CustomRefreshIndicator(
        child: NoAlimentosScreen(),
      );
    }
  }
}

class NoAlimentosScreen extends StatelessWidget {
  const NoAlimentosScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    return InkWell(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CircleAvatar(
            child: Icon(
              Icons.update,
              size: 60,
            ),
            radius: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'Toca para actualizar el menú',
            style: Theme.of(context).textTheme.body2.copyWith(
                fontSize: 14, color: Theme.of(context).primaryColorDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4.5),
          Text(
            'Son vacaciones, o necesitas actualizar el menú',
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      onTap: () => container.showRefreshIndicatorAndUpdate(),
    );
  }
}
