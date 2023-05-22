import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sweet_shop/providers/notificationProvider.dart';
import 'package:sweet_shop/providers/orderProvider.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({Key? key}) : super(key: key);

  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  var isLoading = false;
  var isLoadingInDialog = false;
  var _isFirstTime = true;
  bool _toggled = false;
  String? codeDialog;
  String? valueText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          print("New Notification");
          // if (message.data['_id'] != null) {
          //   Navigator.of(context).push(
          //     MaterialPageRoute(
          //       builder: (context) => DemoScreen(
          //         id: message.data['_id'],
          //       ),
          //     ),
          //   );
          // }
        }
      },
    );

    // 2. This method only call when App in forground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
      (message) {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data11 ${message.data}");
          //LocalNotificationService.createanddisplaynotification(message);
        }
      },
    );

    // 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data22 ${message.data['_id']}");
        }
      },
    );
  }

  final TextEditingController _textFieldController = TextEditingController();
  Future<void> _displayTextInputDialog(
      BuildContext context, String orderKey) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Enter Your Name'),
            content: isLoadingInDialog
                ? Container(
                    child: Text("Please wait..."),
                  )
                : TextField(
                    onChanged: (value) {
                      setState(() {
                        valueText = value;
                      });
                    },
                    controller: _textFieldController,
                    decoration:
                        const InputDecoration(hintText: "Type Name Here"),
                  ),
            actions: <Widget>[
              !isLoadingInDialog
                  ? MaterialButton(
                      color: Colors.red,
                      textColor: Colors.white,
                      child: const Text('CANCEL'),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                        });
                      },
                    )
                  : Container(),
              !isLoadingInDialog
                  ? MaterialButton(
                      color: Colors.green,
                      textColor: Colors.white,
                      child: const Text('OK'),
                      onPressed: (valueText != "" || valueText != null)
                          ? () {
                              isLoadingInDialog = true;
                              updateSeenBy(valueText!, orderKey);
                            }
                          : null,
                    )
                  : Container(),
            ],
          );
        });
  }

  updateSeenBy(String name, String orderKey) {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);

    String month = formattedDate.split("-")[1];
    String year = formattedDate.split("-")[0];
    String date = formattedDate.split("-")[2];
    Provider.of<OrdersProvider>(context, listen: false)
        .updateOrderSeenBy(month, year, date, orderKey, valueText!)
        .then((_) => {
              isLoadingInDialog = false,
              Provider.of<OrdersProvider>(context, listen: false)
                  .selectedOrderKey = orderKey,
              Provider.of<OrdersProvider>(context, listen: false)
                  .selectedOrderType = _toggled ? "custom" : "regular",
              Navigator.pop(context),
              !_toggled
                  ? Navigator.of(context).pushNamed("/regDetail")
                  : Navigator.of(context).pushNamed("/customDetail"),
            });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (_isFirstTime) {
      setState(() {
        isLoading = true;
      });
      var now = new DateTime.now();
      var formatter = new DateFormat('yyyy-MM-dd');
      String formattedDate = formatter.format(now);

      String month = formattedDate.split("-")[1];
      String year = formattedDate.split("-")[0];
      String date = formattedDate.split("-")[2];
      Provider.of<OrdersProvider>(context, listen: false)
          .fetchOrders(month, year, date)
          .then((_) => {
                setState(() => {isLoading = false}),
              });
    }

    _isFirstTime = false;

    super.didChangeDependencies();
  }

  Future<void> fetchOrdersOnRefresh() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);

    String month = formattedDate.split("-")[1];
    String year = formattedDate.split("-")[0];
    String date = formattedDate.split("-")[2];
    return Provider.of<OrdersProvider>(context, listen: false)
        .fetchOrders(month, year, date);
  }

  getAspectList(List<dynamic> allRegularOrders, String type) {
    if (type == "Cake Orders") {
      return allRegularOrders
          .where((order) => order["cakeItems"].length > 0)
          .toList();
    } else {
      return allRegularOrders
          .where((order) => order["snackItems"].length > 0)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    var type = Provider.of<OrdersProvider>(context).workerType;
    var appType = type == "Cake Orders" ? "cakes" : "snacks";
    Provider.of<notificationProvider>(context, listen: false)
        .getDeviceTokenToSendNotification(appType);
    var regularOrderList =
        getAspectList(Provider.of<OrdersProvider>(context).regularOrders, type);
    var customOrderList = Provider.of<OrdersProvider>(context).customOrders;
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
          appBar: AppBar(
            title: Text(type),
          ),
          body: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    type == "Cake Orders"
                        ? Flexible(
                            child: SwitchListTile(
                                activeColor: Colors.green,
                                inactiveTrackColor: Colors.grey,
                                title: Text(
                                  "Show Custom Orders",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                value: _toggled,
                                onChanged: (bool value) {
                                  setState(() {
                                    _toggled = value;
                                  });
                                }),
                            flex: 2)
                        : Container(),
                    Divider(
                      color: Colors.green,
                    ),
                    Flexible(
                        flex: 10,
                        child: !_toggled
                            ? RefreshIndicator(
                                onRefresh: fetchOrdersOnRefresh,
                                backgroundColor: Colors.green,
                                color: Colors.white,
                                child: ListView.builder(
                                  itemCount: regularOrderList.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        _displayTextInputDialog(
                                            context,
                                            regularOrderList[index]
                                                ["orderKey"]);
                                      },
                                      child: Container(
                                        height: 100,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          elevation: 15,
                                          color: (type == "Cake Orders" &&
                                                  regularOrderList[index]
                                                          ["cakesPrepared"] ==
                                                      true)
                                              ? Color(0xff75bde0)
                                              : (type != "Cake Orders" &&
                                                      regularOrderList[index][
                                                              "snacksPrepared"] ==
                                                          true)
                                                  ? Color(0xff75bde0)
                                                  : Color(0xff27ba88),
                                          margin: EdgeInsets.only(
                                              left: 30, right: 30, top: 15),
                                          child: ListTile(
                                            trailing: Icon(
                                              Icons.arrow_forward_ios,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                            title: Text(
                                              regularOrderList[index]
                                                      ["deliveryTime"] +
                                                  " Tak Chahiye ",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Container(
                                              margin: EdgeInsets.only(top: 7),
                                              child: Text(
                                                regularOrderList[index]
                                                            ["Address"] ==
                                                        "SHOP"
                                                    ? "COUNTER ORDER"
                                                    : "REGULAR ORDER",
                                                style: TextStyle(
                                                    backgroundColor:
                                                        Colors.white,
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: fetchOrdersOnRefresh,
                                backgroundColor: Colors.green,
                                color: Colors.white,
                                child: ListView.builder(
                                  itemCount: customOrderList.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        _displayTextInputDialog(context,
                                            customOrderList[index]["orderKey"]);
                                      },
                                      child: Container(
                                        height: 100,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          elevation: 15,
                                          color: customOrderList[index]
                                                      ["status"] ==
                                                  "P"
                                              ? Color(0xff75bde0)
                                              : Color(0xff27ba88),
                                          margin: EdgeInsets.only(
                                              left: 30, right: 30, top: 15),
                                          child: ListTile(
                                            trailing: Icon(
                                              Icons.arrow_forward_ios,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                            title: Text(
                                              regularOrderList[index]
                                                      ["deliveryTime"] +
                                                  " Tak Chahiye ",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Container(
                                              margin: EdgeInsets.only(top: 7),
                                              child: Text(
                                                "CUSTOM ORDER",
                                                style: TextStyle(
                                                    backgroundColor:
                                                        Colors.white,
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ))
                  ],
                ),
        ));
  }
}
