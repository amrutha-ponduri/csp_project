// ignore_for_file: unused_import

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smart_expend/widgets/addexpense_modal.dart';
class DailyExpenses extends StatefulWidget {
  const DailyExpenses({super.key});

  @override
  State<DailyExpenses> createState() => _DailyExpensesState();
}

class _DailyExpensesState extends State<DailyExpenses> {
  var expenseValue=<double>[
      
    ];
    var expenseName = <String>[
      
    ];
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 180, 200, 234),
        title: const Text("Daily Expenses"),
        centerTitle: true,
      ),
      body: expenseName.isEmpty?const Center(
              child: Text('No espenses to display'),
            ): ListView.separated(
        separatorBuilder: (context,index){
          return const SizedBox(height: 0,width: double.infinity,);
          },
        itemCount: expenseName.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClayContainer(
              
              emboss: true,
              borderRadius: 6,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 3,child: ClayText(expenseName[index],emboss: true,color: const Color.fromARGB(255, 145, 185, 218),),),
                    Expanded(flex: 3,child: ClayText(expenseValue[index].toString(),emboss: true,color: const Color.fromARGB(255, 145, 185, 218),),),
                    Expanded(flex: 1,child: InkWell(
                      child: const Icon(
                        Icons.delete,color:  Color.fromARGB(255, 145, 185, 218),
                      ),onTap: () {}
                    ))
                
                  ],
                ),
              ),
            ),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          await showMaterialModalBottomSheet(
            context: context,
            builder: (context) => AddexpenseModal(expenseName,expenseValue)
          );
          print(expenseName);
          print(expenseValue);
          setState(() {
            
          });
        },
        backgroundColor: const Color.fromARGB(255, 180, 200, 234),
        child: const Icon(
          Icons.add,
          color: Colors.blue,
        ),
      ),
    );
  }
}
