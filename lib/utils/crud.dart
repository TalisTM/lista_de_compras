import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lista_de_compras/pages/home.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Crud extends StatefulWidget {
  
  int index;
  
  Crud({this.index});

  @override
  _CrudState createState() => _CrudState();
}

class _CrudState extends State<Crud> {
  
  Map data;

  final produto = TextEditingController();
  final preco = MoneyMaskedTextController(decimalSeparator: ",");
  int quantidade = 1;

  String text;
  
  @override
  void initState() {
    if(widget.index == null){
      text = "Adicionar";
    } else {
      text = "Alterar";
      produto.text = (lista[widget.index]["produto"]); 
      preco.text = (lista[widget.index]["preco"]).toStringAsFixed(2).replaceAll(".", "");
      quantidade = lista[widget.index]["quantidade"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white
      ),
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: produto,
            decoration: InputDecoration(
              hintText: "Produto",
              border: InputBorder.none
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: preco,
                    decoration: InputDecoration(
                    hintText: "Preço",
                    prefix: Text("R\$ "),
                    border: InputBorder.none
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: (){
                  if(quantidade > 1){
                    setState(() {
                      quantidade--;
                    });
                  }
                },
              ),
              Text(quantidade.toString()),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.red),
                onPressed: (){
                  if(quantidade < 100){
                    setState(() {
                      quantidade++;
                    });
                  }
                },
              )
            ],
          ),
          SizedBox(height: 10),
          RaisedButton(
            child: Text(text),
            color: Colors.red,
            textColor: Colors.white,
            padding: EdgeInsets.all(15),
            onPressed: () async {
              if(produto.text.isEmpty){
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Erro!"),
                    content: Text("Digite um nome para o produto"),
                    actions: [
                      FlatButton(
                        child: Text("Ok", style: TextStyle(color: Colors.red)),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                );
              } else {
                if(widget.index == null){
                  data = {
                    "produto" : produto.text,
                    "preco" : (double.parse(preco.text.replaceAll(",", "."))),
                    "quantidade" : quantidade,
                    "status" : double.parse(preco.text.replaceAll(",", ".")) > 0 ? true : false,
                };
                // if(data["status"]){
                //   total += data["preco"] * data["quantidade"];
                // }
                lista.add(data);
                } else {
                  // if(lista[widget.index]["status"]){
                  //   total -= lista[widget.index]["preco"] * lista[widget.index]["quantidade"];
                  // }
                  lista[widget.index]["produto"] = produto.text;
                  lista[widget.index]["preco"] = (double.parse(preco.text.replaceAll(",", ".")));
                  lista[widget.index]["quantidade"] = quantidade;
                  lista[widget.index]["status"] = double.parse(preco.text.replaceAll(",", ".")) > 0 ? true : false;
              
                  // if(lista[widget.index]["status"]){
                  //   total += lista[widget.index]["preco"] * lista[widget.index]["quantidade"];
                  // }
                }
                Future _prefs = SharedPreferences.getInstance();
                SharedPreferences prefs = await _prefs;
                prefs.setString("lista", jsonEncode(lista));
                //print(prefs.getString("lista"));
                Navigator.pop(context);
                setState(() {
                });
              }
            },
          ),
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)
          )
        ],
      ),
    );
  }
}