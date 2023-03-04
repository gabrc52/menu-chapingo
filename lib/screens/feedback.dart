import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  String get feedback => _controller.text;
  final _formKey = GlobalKey<FormState>();
  // ignore: unused_field
  bool _autoValidate = false; // Dart seems to incorrectly think it's unused
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
      autovalidateMode: AutovalidateMode.disabled,
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
                  if (value == null || value.isEmpty) {
                    return 'En blanco';
                  }
                  return null;
                },
                controller: _controller,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                  'Al enviar comentarios, podrás recibir una respuesta por medio de una notificación.',
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.justify),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendFeedback() async {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Enviando tus comentarios...'),
        duration: Duration(hours: 1),
      ));

      const url =
          'https://docs.google.com/forms/d/e/1FAIpQLSdJwnwjmpxZt3vHlrlHgofb4gqYAXajDrlYPDIqjnH3QfYtmQ/formResponse';
      const feedback_field = 'entry.1589179264';
      const contact_field = 'entry.1786043628';
      String? token;
      late String buildNumber;
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        buildNumber = packageInfo.buildNumber;
        token = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        token = 'NA:$e';
      } finally {
        try {
          final db = FirebaseFirestore.instance;
          final feedbackRef = db.collection('feedback');
          await feedbackRef.add({
            'feedback': feedback,
            'type': 'app',
            'token': token,
            'buildNumber': buildNumber,
            'date': DateTime.now(),
          });
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        } catch (e) {
          /// TODO: instead, use firebase database and offline mode. this can potentially enable a chat-like page
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
