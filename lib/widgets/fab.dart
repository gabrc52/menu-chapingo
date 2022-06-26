import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import '../state_container.dart';

class Fab extends StatelessWidget {
  const Fab({Key? key}) : super(key: key);

  static Future<void> changeDate(BuildContext context) async {
    final container = StateContainer.of(context);

    // flutter's date picker asserts that initialDate is between firstDate and lastDate
    final DateTime? fechaNueva = await showDatePicker(
      context: context,
      initialDate: container.state.fecha,
      firstDate: container.state.inicio,
      lastDate: container.state.fin,
      textDirection: TextDirection.ltr,
    );
    if (fechaNueva != null) {
      container.goToDate(fechaNueva);
    }
  }

  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    return FloatingActionButton(
      onPressed: () => changeDate(context),
      tooltip: 'Cambiar día',
      child: Icon(UniversalPlatform.isIOS
          ? (container.state.isToday
              ? CupertinoIcons.calendar_today
              : CupertinoIcons.calendar)
          : Icons.event),
    );
  }
}
