import 'package:flutter/material.dart';
import 'package:menu2018/state_container.dart';

class Fab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final container = StateContainer.of(context);

    Future<void> _changeDate() async {
      // flutter's date picker asserts that initialDate is between firstDate and lastDate
      final DateTime fechaNueva = await showDatePicker(
        context: context,
        initialDate: container.state.fecha,
        firstDate: container.state.inicio,
        lastDate: container.state.fin,
        textDirection: TextDirection.ltr,
      );
      container.goToDate(fechaNueva);
    }

    return FloatingActionButton(
      onPressed: _changeDate,
      tooltip: 'Cambiar día',
      child: const Icon(Icons.event),
    );
  }
}