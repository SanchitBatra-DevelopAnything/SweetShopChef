import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    var type = Provider.of<OrdersProvider>(context).workerType;
    var regularOrderList = Provider.of<OrdersProvider>(context).regularOrders;
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
                    Flexible(
                        child: type == "Cake Orders"
                            ? SwitchListTile(
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
                                })
                            : Container(),
                        flex: 2),
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
                                          color: Colors.green,
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
                                              ? Colors.red
                                              : Colors.green,
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
