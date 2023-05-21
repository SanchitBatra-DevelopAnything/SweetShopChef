import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sweet_shop/providers/orderProvider.dart';

class RegularOrderDetail extends StatefulWidget {
  const RegularOrderDetail({Key? key}) : super(key: key);

  @override
  _RegularOrderDetailState createState() => _RegularOrderDetailState();
}

class _RegularOrderDetailState extends State<RegularOrderDetail> {
  var _isFirstTime = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (_isFirstTime) {
      Provider.of<OrdersProvider>(context, listen: false)
          .getSelectedOrderItemsList();
    }
    _isFirstTime = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var ItemList = Provider.of<OrdersProvider>(context).selectedOrderItemsList;
    var workerType = Provider.of<OrdersProvider>(context).workerType;
    var selectedOrderKey =
        Provider.of<OrdersProvider>(context).selectedOrderKey;
    var particulars = Provider.of<OrdersProvider>(context, listen: false)
        .getSelectedOrderParticulars("regular");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Order Details",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : Column(
              children: [
                Flexible(
                  flex: 10,
                  child: ListView.builder(
                    itemCount: ItemList.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                          activeColor: Colors.green,
                          title: Text(
                            '${ItemList[index]['quantity']} x ${ItemList[index]['name']}',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          value: ItemList[index]["prepared"] == "YES"
                              ? true
                              : false,
                          onChanged: (value) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Sure?"),
                                content: const Text(
                                    "The selected item will be updated."),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      var now = new DateTime.now();
                                      var formatter =
                                          new DateFormat('yyyy-MM-dd');
                                      String formattedDate =
                                          formatter.format(now);

                                      String month =
                                          formattedDate.split("-")[1];
                                      String year = formattedDate.split("-")[0];
                                      String date = formattedDate.split("-")[2];
                                      Provider.of<OrdersProvider>(context,
                                              listen: false)
                                          .updateOrderItems(month, year, date,
                                              index, value!, selectedOrderKey)
                                          .then((_) => {
                                                setState(() {
                                                  _isLoading = false;
                                                })
                                              });
                                    },
                                    child: Container(
                                      color: Colors.green,
                                      padding: const EdgeInsets.all(14),
                                      child: const Text(
                                        "OKAY",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                    },
                  ),
                ),
                (particulars != "" && particulars != null)
                    ? Divider(
                        color: Colors.black,
                      )
                    : Container(),
                (particulars != "" && particulars != null)
                    ? Flexible(
                        flex: 4,
                        child: Text(
                          particulars,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(),
              ],
            ),
    );
  }
}
