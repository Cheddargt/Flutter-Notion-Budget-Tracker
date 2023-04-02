import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_notion_budget/budget_repository.dart';
import 'package:flutter_notion_budget/failure_model.dart';
import 'package:flutter_notion_budget/item_model.dart';
import 'package:flutter_notion_budget/spending_chart.dart';
import 'package:intl/intl.dart';

void main() async {
  //  não sabia que a main podia ser async
  await dotenv
      .load(fileName: '.env'); //  carrega a chave da API e o id do database
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notion Budget Tracker',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: BudgetScreen(),
    );
  }
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late Future<List<Item>> _futureItems;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureItems = BudgetRepository().getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: const Text('Budget Tracker'),
        ),
        body: RefreshIndicator(
          onRefresh: () async { 
            _futureItems = BudgetRepository().getItems();
            setState(() {});
           },
          child: FutureBuilder<List<Item>>(
              future: _futureItems,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final items = snapshot.data!;
                  return ListView.builder(
                    itemCount: items.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) return SpendingChart(items: items);
        
                      final item = items[index - 1];
                      final time = DateFormat.Hm().format(item.date);
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            width: 2.0,
                            color: getCategoryColor(item.category),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                            '${item.category} • ${DateFormat.yMd().format(item.date)}${time != '00:00' ? (' • $time') : ''}'),
                            trailing: Text('-R\$${item.price.toStringAsFixed(2)}'),
                        )
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  // acho que é um cast para Failure pq o erro é um objeto genérico
                  // e não temos acesso aos atributos dele sem fazer o cast para Failure
                  final failure = snapshot.error as Failure;
                  return Center(
                    child: Text(failure.message),
                  );
                }
                // se não tem dados nem erro, mostra um loading
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }),
        ));
  }
}

Color getCategoryColor(String category) {
  switch (category) {
    case 'Alimentação': 
      return Colors.green[400]!;
    case 'Aniversários': 
      return Colors.pink[400]!;
    case 'Entretenimento': 
      return Colors.brown[400]!;
    case 'Jogos': 
      return Colors.purple[400]!;
    case 'Paula': 
      return Colors.red[400]!;
    case 'Pessoal': 
      return Colors.green[400]!;
    case 'Presentes': 
      return Colors.pink[400]!;
    case 'Saúde': 
      return Colors.orange[400]!;
    case 'Transporte': 
      return Colors.blue[400]!;
    case 'Larissa': 
      return Colors.red[400]!;
    case 'Família': 
      return Colors.red[400]!;
    case 'Mensal': 
      return Colors.grey[400]!;
    default: 
      return Colors.grey[800]!;
  }
}