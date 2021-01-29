import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:email_validator/email_validator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_contatos/helpers/contact_helper.dart';

class ContactPage extends StatefulWidget {

  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  Contact _editedContact;

  bool _userEdited = false;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.contact == null){
      _editedContact = Contact();
    } else {
      _editedContact = widget.contact;
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _requestDialog,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(_editedContact.name ?? "Novo Contato"),
            centerTitle: true,
            backgroundColor: Colors.red,
            elevation: 0.0,
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: (){
              if(formKey.currentState.validate()){
                Navigator.pop(context, _editedContact);
              }
            },
            child: Icon(Icons.save),
            elevation: 0.0,
          ),
          body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {_getImage();},
                      child: Container(
                        width: 120.0,
                        height: 120.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 3 ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(1),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                // fit: BoxFit.cover,
                                image: _editedContact.img != null ?
                                FileImage(File(_editedContact.img)) :
                                AssetImage("assets/person.png")
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: "Nome", hintText: "Digite o nome do contato"),
                      keyboardType: TextInputType.name,
                      onChanged: (text){
                        _userEdited = true;
                        setState(() {
                          _editedContact.name = text;
                        });
                      },
                      validator: (value) {
                        if(value.isEmpty || value == null){
                          return "Insira o nome";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: "E-mail", hintText: "Digite o e-mail do contato"),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (text){
                        _userEdited = true;
                        _editedContact.email = text;
                      },
                      validator: (value) {
                        if(value.isEmpty || value == null || !EmailValidator.validate(value)){
                          return "Insira um e-mail válido";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: "Telefone", hintText: "Digite o telefone do contato"),
                      keyboardType: TextInputType.phone,
                      onChanged: (text){
                        _userEdited = true;
                        _editedContact.phone = text;
                      },
                      validator: (value) {
                        if(value.isNotEmpty && value.length<8){
                          return "Insira um telefone válido";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              )
          ),
        ),
    );
  }

  Future<bool> _requestDialog(){
    if(_userEdited){
      showDialog(context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Descartar alterações?"),
            content: Text("Suas alterações serão perdidas. Deseja prosseguir?"),
            actions: <Widget>[
              FlatButton(
                  onPressed: (){
                    Navigator.pop(context);
                    },
                  child: Text("CANCELAR")
              ),
              FlatButton(
                  onPressed: (){
                    Navigator.pop(context);
                    Navigator.pop(context);
                    },
                  child: Text("SAIR")
              ),
            ],
          );
        }
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  Future _getImage() async{
    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
    if(pickedFile != null) {
      File croppedImage = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        maxWidth: 1080,
        maxHeight: 1080,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
      );
      if(croppedImage != null) {
        setState(() {
          _editedContact.img = croppedImage.path;
        });
      }else {
        setState(() {
          _editedContact.img = pickedFile.path;
        });
      }
    } else {
      return;
    }
  }

  Future _cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: filePath,
      maxWidth: 1080,
      maxHeight: 1080,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
    );
    print(croppedImage);
    if(croppedImage != null) {
      setState(() {
        _editedContact.img = filePath;
      });
    } else {
      return;
    }
  }
}
