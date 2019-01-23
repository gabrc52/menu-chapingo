import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info/package_info.dart';

class FeedbackPage extends StatefulWidget {
  @override
  FeedbackPageState createState() {
    return FeedbackPageState();
  }
}

class FeedbackPageState extends State<FeedbackPage> {
  String get feedback => _controller.text;
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  final _controller = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Enviar comentarios'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendFeedback,
              tooltip: 'Enviar',
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                maxLines: null,
                autofocus: true,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Describe el problema o comparte tus ideas',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'En blanco';
                  }
                },
                controller: _controller,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Al enviar comentarios, podrás recibir una respuesta por medio de una notificación.',
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.justify
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendFeedback() async {
    if (_formKey.currentState.validate()) {
      _scaffoldKey.currentState.showSnackBar(const SnackBar(
        content: Text('Enviando tus comentarios...'),
        duration: Duration(hours: 1),
      ));

      const url =
          'https://docs.google.com/forms/d/e/1FAIpQLSdJwnwjmpxZt3vHlrlHgofb4gqYAXajDrlYPDIqjnH3QfYtmQ/formResponse';
      const feedback_field = 'entry.1589179264';
      const contact_field = 'entry.1786043628';
      String token;
      String buildNumber;
      try {
        token = await FirebaseMessaging().getToken();
        final packageInfo = await PackageInfo.fromPlatform();
        buildNumber = packageInfo.buildNumber;
      } catch (e) {
        token = 'NA:$e';
      } finally {
        try {
          final response = await http.post(
            url,
            body: {
              feedback_field: feedback,
              contact_field: 'Token: $token\nVersión: $buildNumber\n',
            },
          );
          if (response.statusCode == 200 &&
              response.body.contains('Gracias por tus comentarios.')) {
            Navigator.of(context).pop(true);
          }
        } catch (e) {
          // TODO: intentar usar messenger, pues se enviará cuando haya internet
          _scaffoldKey.currentState.showSnackBar(const SnackBar(
            content: Text(
                'Ocurrió un error al enviar tus comentarios. Verifica tu conexión, o inténtalo más tarde.'),
          ));
        }
      }
    } else {
      setState(() => _autoValidate = true);
    }
  }
}
