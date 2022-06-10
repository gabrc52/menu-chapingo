import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'models.dart';

// TODO: Move to provider, or something else.
// I am doing shenanigans trying to migrate this to nulll safety

class StateContainer extends StatefulWidget {
  const StateContainer({
    required this.child,
    this.state,
  });

  final AppState? state;
  final Widget child;

  @override
  State<StateContainer> createState() => _StateContainerState();

  static _StateContainerState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedStateContainer>()
        ?.data;
  }
}

class _StateContainerState extends State<StateContainer> {
  late AppState state;

  @override
  void initState() {
    super.initState();
    state = widget.state!;
  }

  String get title => state.getTitle();

  void goToDate(DateTime? date) {
    setState(() => state.goToDate(date ?? state.fecha));
  }

  VoidCallback? get incrementDate {
    if (state.noAlimentos) return null;
    return state.canIncrement
        ? () => setState(() => state.incrementDate())
        : null;
  }

  VoidCallback? get decrementDate {
    if (state.noAlimentos) return null;
    return state.canDecrement
        ? () => setState(() => state.decrementDate())
        : null;
  }

  VoidCallback? get today {
    if (state.noAlimentos) return null;
    return state.isToday ? null : () => setState(() => state.goToToday());
  }

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey();

  void showRefreshIndicatorAndUpdate() {
    refreshIndicatorKey.currentState?.show();
  }

  bool hasDoneFirstRefresh = false;
  Future<void> firstRefresh() async {
    if (!hasDoneFirstRefresh) {
      refreshIndicatorKey.currentState?.show();
      hasDoneFirstRefresh = true;
    }
  }

  DateTime lastUpdate = DateTime.fromMicrosecondsSinceEpoch(0);
  RefreshCallback update(BuildContext context) {
    return () async {
      void showSnackBar(
          {required String content, bool showRetryButton = true}) {
        if (DateTime.now().isAfter(lastUpdate)) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(content),
              action: showRetryButton
                  ? SnackBarAction(
                      label: 'Reintentar',
                      onPressed: () {
                        showRefreshIndicatorAndUpdate();
                      },
                    )
                  : null,
            ),
          );
        }
      }

      const no_hay_internet =
          'No se pudo actualizar. Verifica tu conexión a internet.';

      try {
        lastUpdate = DateTime.now();
        await state.update();
        setState(() {});
      } on SocketException {
        showSnackBar(content: no_hay_internet);
      } on HttpException {
        showSnackBar(content: no_hay_internet);
      } on FormatException {
        // TODO: reportar el error al instante
        showSnackBar(content: 'Error al actualizar.', showRetryButton: false);
      } catch (e, s) {
        showSnackBar(
            content: 'Error al actualizar. ¿Estás conectado a internet?');
        print('$e\n$s');
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedStateContainer extends InheritedWidget {
  const _InheritedStateContainer({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  final _StateContainerState data;

  // siempre true, como en el ejemplo en flutter_architecture_samples
  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
