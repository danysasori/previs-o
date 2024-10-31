import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PrevisaoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Previsao {
  final String data;
  final double temperatura;
  final double umidade;
  final double luminosidade;
  final double vento;
  final double chuva;
  final String unidade;

  Previsao({
    required this.data,
    required this.temperatura,
    required this.umidade,
    required this.luminosidade,
    required this.vento,
    required this.chuva,
    required this.unidade,
  });

  factory Previsao.fromJson(Map<String, dynamic> json) {
    return Previsao(
      data: json['data'],
      temperatura: json['temperatura'].toDouble(),
      umidade: json['umidade'].toDouble(),
      luminosidade: json['luminosidade'].toDouble(),
      vento: json['vento'].toDouble(),
      chuva: json['chuva'].toDouble(),
      unidade: json['unidade'],
    );
  }
}

class PrevisaoPage extends StatefulWidget {
  @override
  _PrevisaoPageState createState() => _PrevisaoPageState();
}

class _PrevisaoPageState extends State<PrevisaoPage> {
  late Future<List<Previsao>> previsoes;

  Future<List<Previsao>> fetchPrevisoes() async {
    final response =
        await http.get(Uri.parse('https://demo3520525.mockable.io/previsao'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Previsao.fromJson(data)).toList();
    } else {
      throw Exception('Erro ao carregar previsoes');
    }
  }

  @override
  void initState() {
    super.initState();
    previsoes = fetchPrevisoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Previsao do Tempo"),
      ),
      body: FutureBuilder<List<Previsao>>(
        future: previsoes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Nenhuma previsao disponivel"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final previsao = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      "${previsao.data} - ${previsao.temperatura}°${previsao.unidade}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Umidade: ${previsao.umidade}% | Luminosidade: ${previsao.luminosidade}\n"
                      "Vento: ${previsao.vento} km/h | Chuva: ${previsao.chuva} mm",
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
