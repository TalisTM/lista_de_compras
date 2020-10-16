import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lista_de_compras/utils/crud.dart';
import 'package:shared_preferences/shared_preferences.dart';

List lista = [];
double total = 0;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Future executar (context) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String lista2 = _prefs.getString("lista");

    if(lista2 == null){
      lista = [];
    } else {
      lista = jsonDecode(lista2);
    }
  }

  void _setTotal(){
    total = 0;
    lista.forEach((p) {
      if(p["status"]){
        total += p["preco"] * p ["quantidade"];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    executar(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Compras"),
        centerTitle: true,
        elevation: 0.4,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white,),
            onPressed: (){
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Atenção"),
                  content: Text("Deseja apagar todos os itens"),
                  actions: [
                    FlatButton(
                      child: Text("Cancelar", style: TextStyle(color: Colors.red)),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text("Confirmar", style: TextStyle(color: Colors.red)),
                      onPressed: () async {
                        total = 0;
                        lista.clear();
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.remove("lista");
                        Navigator.pop(context);
                        setState(() {
                        });
                      },
                    )
                  ],
                )
              );
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: executar(context),
        builder: (context, snapshot){
          return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: lista.length,
                itemBuilder: (context, index) {
                  _setTotal();
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                    });
                  });
                  return GestureDetector(
                    child: CheckboxListTile(
                      value: lista[index]["status"],
                      title: Text("${lista[index]["quantidade"]}x ${lista[index]["produto"]}"),
                      subtitle: Text("R\$ ${lista[index]["preco"].toStringAsFixed(2)}"),
                      activeColor: Colors.red,
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary: IconButton(
                        icon: Icon(Icons.edit, color: Colors.red),
                        onPressed: () async {
                          await showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            useRootNavigator: true,
                            context: context,
                            builder: (context){
                              return Crud(index: index);
                            }
                          );
                          setState(() {
                          });
                        },
                      ),
                      onChanged: (value)async {
                          if(lista[index]["preco"] > 0){
                            lista[index]["status"] = value;
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.setString("lista", jsonEncode(lista));
                            setState(() {
                            });
                          }
                      },
                    ),
                    onLongPress: (){
                      showDialog(
                        context: context,
                        builder: (context){
                          return AlertDialog(
                            title: Text("Atenção"),
                            content: Text("Realmente deseja remover este item"),
                            actions: [
                              FlatButton(
                                child: Text("Cancelar", style: TextStyle(color: Colors.red)),
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                              ),
                              FlatButton(
                                child: Text("Confirmar", style: TextStyle(color: Colors.red)),
                                onPressed: () async {
                                  if(lista[index]["status"]){
                                    total -= lista[index]["preco"] * lista[index]["quantidade"];
                                  }
                                  lista.removeAt(index);
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  prefs.setString("lista", jsonEncode(lista));
                                  Navigator.pop(context); 
                                  setState(() {
                                  });
                                },
                              )
                            ],
                          );
                        }
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              color: Colors.red,
              padding: EdgeInsets.all(10),
              child: Text(
                "R\$ ${total.toStringAsFixed(2)}",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)
              ),
            )
          ],
        );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.red[800],
        onPressed: () async {
          await showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            builder: (context){
              return Crud();
            }
          );
          setState(() {
          });
        },
      )
    );
  }
}
