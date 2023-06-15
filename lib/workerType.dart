import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sweet_shop/providers/orderProvider.dart';

class WorkerType extends StatefulWidget {
  const WorkerType({Key? key}) : super(key: key);

  @override
  _WorkerTypeState createState() => _WorkerTypeState();
}

class _WorkerTypeState extends State<WorkerType> {
  var type = "Cake Orders";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          bool willLeave = false;
          // show the confirm dialog
          await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    title: const Text('Are you sure want to exit the app?'),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            willLeave = true;
                            SystemNavigator
                                .pop(); //yahan app band ho jaani chahiye! , autoLogin ke baad autoLoad se jab back jaara hu to whoUser() dikhra h dont know y! , isliye yhan forcefully quit kro.
                          },
                          child: const Text('Yes')),
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('No'))
                    ],
                  ));
          return willLeave;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.green,
            title: Text(
              "SELECT TYPE",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          body: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Sweet Shop",
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
              Divider(
                color: Colors.black,
              ),
              Container(
                child: RadioListTile(
                  value: "Snacks , Paneer & Chaap Orders",
                  groupValue: type,
                  onChanged: (value) {
                    setState(() {
                      type = value.toString();
                    });
                  },
                  activeColor: Colors.green,
                  title: Text(
                    "Snacks , Paneer & Chaap Orders",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Select this if you are a snacks worker",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                child: RadioListTile(
                  value: "Cake Orders",
                  groupValue: type,
                  onChanged: (value) {
                    setState(() {
                      type = value.toString();
                    });
                  },
                  title: Text(
                    "Cake Orders",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  activeColor: Colors.green,
                  subtitle: Text(
                    "Select this if you are a cake worker",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<OrdersProvider>(context, listen: false)
                      .workerType = type;
                  Navigator.of(context).pushReplacementNamed('/orders');
                },
                style: ElevatedButton.styleFrom(primary: Colors.green),
                child: Text(
                  "PROCEED",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          )),
        ));
  }
}
