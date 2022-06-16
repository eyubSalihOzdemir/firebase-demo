import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:pie_chart/pie_chart.dart';

class StatisticsScreen extends StatefulWidget {
  StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

Future<List<Map<String, dynamic>>> getData() async {
  List<Map<String, dynamic>> itemList = [];

  //initializing cloud firestore ref
  var db = FirebaseFirestore.instance;

  // get each item from share_holders collection and add it to a list of Maps
  await db.collection("share_holders").get().then((event) {
    for (var doc in event.docs) {
      //print("${doc.id} => ${doc.data()}");
      itemList.add(doc.data());
    }
  });

  return itemList;
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<List<Map<String, dynamic>>> _listResult;
  double totalPercentage = 100;

  @override
  void initState() {
    super.initState();
    _listResult = getData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _listResult,
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          Map<String, double> dataMap = {};

          // iterate through items list and add each data to dataMap variable to be shown in the pie chart
          for (Map<String, dynamic> item in snapshot.data as List) {
            final info = <String, double>{
              "${item['name']} (age: ${item['age']})":
                  double.parse(item['share_percentage'])
            };
            totalPercentage -= info.values.first;
            dataMap.addEntries(info.entries);
          }

          // if there are less than 100 shares, show the rest with the label "Other"
          if (totalPercentage > 0) {
            final info = <String, double>{"Other": totalPercentage};
            dataMap.addEntries(info.entries);
          }

          // pie chart package
          return PieChart(
            dataMap: dataMap,
            chartLegendSpacing: 16,
            chartRadius: MediaQuery.of(context).size.width * 0.9,
            chartType: ChartType.disc,
            centerText: "Share Percentages",
            legendOptions: LegendOptions(
              showLegendsInRow: false,
              legendPosition: LegendPosition.top,
            ),
            chartValuesOptions: ChartValuesOptions(
              showChartValueBackground: true,
              showChartValues: true,
              showChartValuesInPercentage: true,
              showChartValuesOutside: false,
              decimalPlaces: 0,
              chartValueStyle: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          );
        } else {
          // return nothing if data has not been received yet
          return Container();
        }
      },
    );
  }
}
