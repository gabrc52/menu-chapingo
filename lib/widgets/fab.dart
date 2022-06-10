import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../state_container.dart';
import 'dart:io';
import 'package:cupertino_icons/cupertino_icons.dart';

class Fab extends StatelessWidget {
  static Future<void> changeDate(BuildContext context) async {
    final container = StateContainer.of(context);

    // flutter's date picker asserts that initialDate is between firstDate and lastDate
    final DateTime? fechaNueva = await showDatePicker(
      context: context,
      initialDate: container!.state.fecha,
      firstDate: container!.state.inicio,
      lastDate: container!.state.fin,
      textDirection: TextDirection.ltr,
    );
    if (fechaNueva != null) {
      container?.goToDate(fechaNueva);
    }
  }

  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);
    return FloatingActionButton(
      onPressed: () => changeDate(context),
      tooltip: 'Cambiar día',
      child: Icon(Platform.isIOS
          ? ((container?.state.isToday ?? false)
              ? CupertinoIcons.calendar_today
              : CupertinoIcons.calendar)
          : Icons.event),
    );
  }
}
