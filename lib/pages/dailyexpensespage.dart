import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DailyExpenses extends StatelessWidget {
  const DailyExpenses({super.key});
  @override
  Widget build(BuildContext context) {
    var price=[
      100,200,300,100,200,300,100,200,300,100,200,300,100,200,300,100,200,300,100,200,300,100,200,300,100,200,300,100,200,300,100,200,300,100,200,300,100,200,300,100,200,300,100,200,300,100,200,300,
    ];
    var expenseName = [
      'Snacks',
      'Food',
      'Party',
      'Beach',
      'Momos',
      'Snacks',
      'Food',
      'Party',
      'Beach',
      'Momos',
      'Snacks',
      'Food',
      'Party',
      'Beach',
      'Momos',
      'Snacks',
      'Food',
      'Party',
      'Beach',
      'Momos'
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 180, 200, 234),
        title: const Text("Daily Expenses"),
        centerTitle: true,
      ),
      body: ListView.separated(
        separatorBuilder: (context,index){
          return SizedBox(height: 5,width: double.infinity,);
          },
        itemCount: expenseName.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 200, 225, 245),
              borderRadius: BorderRadius.circular(3),
              // boxShadow: [
              //   BoxShadow(
              //     color: const Color.fromARGB(255, 172, 183, 194),
              //     spreadRadius: 2,
              //     blurRadius: 2,
              //   )
              // ]
            ),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: Text(expenseName[index]),flex: 3,),
                  Expanded(child: Text(price[index].toString()),flex: 3,),
                  Expanded(flex: 1,child: Icon(
                    Icons.delete,color: const Color.fromARGB(255, 45, 148, 232),
                  ))
              
                ],
              ),
            ),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color.fromARGB(255, 180, 200, 234),
        child: const Icon(
          Icons.add,
          color: Colors.blue,
        ),
      ),
    );
  }
}
