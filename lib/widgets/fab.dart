import 'dart:async';
import 'package:flutter/material.dart';
import '../state_container.dart';

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
    return FloatingActionButton(
      onPressed: () => changeDate(context),
      tooltip: 'Cambiar día',
      child: const Icon(Icons.event),
    );
  }
}
