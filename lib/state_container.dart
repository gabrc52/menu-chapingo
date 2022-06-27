import 'dart:async';
import 'dart:io';
import 'package:app_install_date/app_install_date.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/app_state.dart';

// TODO: Move to provider, or something else.
// I am doing shenanigans trying to migrate this to null safety

// Well, provider is a wrapper around inherited widgets...

class StateContainer extends StatefulWidget {
  const StateContainer({
    required this.child,
    required this.state,
    Key? key,
  }) : super(key: key);

  final AppState state;
  final Widget child;

  @override
  State<StateContainer> createState() => StateContainerState();

  static StateContainerState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedStateContainer>()!
        .data;
  }
}

class StateContainerState extends State<StateContainer> {
  AppState get state => widget.state;

  @override
  void initState() {
    super.initState();
    conditionallyRequestReview();
  }

  Future<void> conditionallyRequestReview() async {
    final installDate = await AppInstallDate().installDate;
    final prefs = await SharedPreferences.getInstance();
    final bool hasRequestedBefore =
        prefs.getBool('has-requested-review') ?? false;
    final installedTime = DateTime.now().difference(installDate);
    if (!hasRequestedBefore && installedTime.inDays >= 10) {
      final InAppReview inAppReview = InAppReview.instance;
      final canReview = await inAppReview.isAvailable();
      if (canReview) {
        try {
          inAppReview.requestReview();
          prefs.setBool('has-requested-review', true);
        } catch (e) {
          prefs.setBool('has-requested-review', false);
        }
      }
    }
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
          ScaffoldMessenger.of(context).showSnackBar(
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
        debugPrint('$e\n$s');
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

  final StateContainerState data;

  // siempre true, como en el ejemplo en flutter_architecture_samples
  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
