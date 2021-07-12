import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:keep_on_moving/services/auth.dart';
import 'package:keep_on_moving/widgets/LoadingWidget.dart';

import 'ToastMessage.dart';

class RegistrationScreen extends StatefulWidget {

  final Function? toggleView;
  RegistrationScreen({ this.toggleView });

  @override
  _RegistrationScreen createState() => _RegistrationScreen();
}

class _RegistrationScreen extends State<RegistrationScreen> {

  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String name = "";
  String email = "";
  String password = "";
  String passwordRep = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      appBar: AppBar(
        title: Text('Keep on Moving'),
        actions: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.person),
              label: Text('Login'),
              onPressed: () => widget.toggleView!(),
            ),
          ],
        ),
      body: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height:50),
              TextFormField(
                keyboardType: TextInputType.text,
                autocorrect: false,
                validator: (value) => value!.isEmpty ? 'Benutzername eingeben' : null,
                decoration: InputDecoration(
                  labelText: 'Benutzername', border: OutlineInputBorder()
                ),
                onChanged: (value) {
                    setState(() => name = value);
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: (value) => value!.isEmpty ? 'E-Mail Adresse eingeben' : null,
                decoration: InputDecoration(
                  labelText: 'Email-Adresse', border: OutlineInputBorder()),
                onChanged: (value) {
                  setState(() => email = value);
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Passwort muss mindestens 6 Zeichen enthalten' : null,
                decoration: InputDecoration(
                  labelText: 'Passwort', border: OutlineInputBorder()),
                onChanged: (value) {
                  setState(() => password = value);
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                obscureText: true,
                validator: (value) => value!.isEmpty || value != password ? 'Passwörter stimmen nicht überein' : null,
                decoration: InputDecoration(
                  labelText: 'Passwort wiederholen',
                  border: OutlineInputBorder()),
                onChanged: (value) {
                setState(() => passwordRep = value);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Registrieren'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => loading = true);
                    dynamic result = await AuthService().registerWithEmail(
                        name, email, password);
                    if (result == null) {
                      setState(() {
                        error = 'Bitte eine gültige Email Adresse eingeben';
                        loading = false;
                      });
                    }
                    else{
                      Navigator.pushNamed(context, 'HomeScreen');
                    }
                  }
                },
              ),
              SizedBox(height: 20),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14.0),
              ),
          ],
        ),
      ),
    );
  }
}
