import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:keep_on_moving/services/auth.dart';
import 'package:keep_on_moving/widgets/LoadingWidget.dart';

import 'ToastMessage.dart';

class LoginScreen extends StatefulWidget {

  final Function? toggleView;
  LoginScreen({ this.toggleView });

  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String name = "";
  String password = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      appBar: AppBar(
        title: Text('Keep on Moving'),
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.person),
            label: Text('Registrieren'),
            onPressed: () => widget.toggleView!(),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              validator: (value) => value!.isEmpty ? 'Email-Adresse eingeben' : null,
              onChanged: (value) {
                name = value;
              },
              decoration: InputDecoration(
                  focusColor: Colors.green,
                  labelText: 'E-Mail', border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            TextFormField(
              obscureText: true,
              validator: (value) => value!.isEmpty ? 'Passwort eingeben' : null,
              onChanged: (value) {
                password = value;
              },
              decoration: InputDecoration(
                  labelText: 'Passwort', border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if(_formKey.currentState!.validate()){
                      setState(() => loading = true);
                      dynamic result = await AuthService().loginWithUser(name, password);
                      if(result == null){
                        setState(() {
                          error = 'Login war nicht erfolgreich.';
                          loading = false;
                        });
                      }
                      else{
                        Navigator.pushNamed(context, 'HomeScreen');
                      }
                    }
                  },
                  child: Text('Login'),
                ),
                SizedBox(height: 20),
                Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
