import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sweet_shop/providers/orderProvider.dart';
import 'package:widget_zoom/widget_zoom.dart';

class CustomOrderDetail extends StatefulWidget {
  const CustomOrderDetail({Key? key}) : super(key: key);

  @override
  _CustomOrderDetailState createState() => _CustomOrderDetailState();
}

var _isLoading = false;
var _markedPrepared = false;

class _CustomOrderDetailState extends State<CustomOrderDetail> {
  @override
  Widget build(BuildContext context) {
    var selectedOrderKey =
        Provider.of<OrdersProvider>(context).selectedOrderKey;
    var particulars = Provider.of<OrdersProvider>(context, listen: false)
        .getSelectedOrderParticulars("custom");
    var flavour =
        Provider.of<OrdersProvider>(context, listen: false).getFlavour();
    var weight = Provider.of<OrdersProvider>(context, listen: false).getPound();
    var message =
        Provider.of<OrdersProvider>(context, listen: false).getMessage();
    var imgUrl =
        Provider.of<OrdersProvider>(context, listen: false).getImgUrl();
    var photoUrl =
        Provider.of<OrdersProvider>(context, listen: false).getPhotoUrl();
    _markedPrepared = Provider.of<OrdersProvider>(context).getCakeStatus();
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Sure?"),
                      content: const Text(
                          "The selected order will be marked prepared and will not be modified later."),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            setState(() => {
                                  _isLoading = true,
                                  _markedPrepared = true,
                                });
                            var now = new DateTime.now();
                            var formatter = new DateFormat('yyyy-MM-dd');
                            String formattedDate = formatter.format(now);

                            String month = formattedDate.split("-")[1];
                            String year = formattedDate.split("-")[0];
                            String date = formattedDate.split("-")[2];
                            Provider.of<OrdersProvider>(context, listen: false)
                                .updateOrder(month, year, date, "custom",
                                    selectedOrderKey)
                                .then((_) => {
                                      setState(() => {_isLoading = false})
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
                },
                child: !_markedPrepared
                    ? Icon(
                        Icons.done_all,
                        size: 26.0,
                      )
                    : Container(),
              )),
        ],
        title: Text(
          "Order Detail",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
      body: !_isLoading
          ? SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 30),
                  ),
                  imgUrl != "not-uploaded"
                      ? WidgetZoom(
                          zoomWidget: Card(
                            child: Image.network(imgUrl, frameBuilder: (context,
                                child, frame, wasSynchronouslyLoaded) {
                              return child;
                            }, loadingBuilder:
                                (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }),
                            elevation: 10,
                          ),
                          heroAnimationTag: 'tag',
                        )
                      : Container(
                          child: Center(
                          child: Text("No image available"),
                        )),
                  Padding(
                    padding: EdgeInsets.only(bottom: 30),
                  ),
                  photoUrl != "not-uploaded"
                      ? WidgetZoom(
                          zoomWidget: Card(
                            elevation: 10,
                            child: Image.network(photoUrl, frameBuilder:
                                (context, child, frame,
                                    wasSynchronouslyLoaded) {
                              return child;
                            }, loadingBuilder:
                                (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }),
                          ),
                          heroAnimationTag: 'tag',
                        )
                      : Container(
                          child: Center(child: Text("Photo Cake nahi hai!")),
                        ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 30),
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 1,
                  ),
                  Text(
                    "Flavour : " + flavour,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Pounds : " + weight.toString() + " Pounds",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  message != ""
                      ? Text(
                          "Message : " + message,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )
                      : Container(),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 1,
                  ),
                  Text(
                    "Instructions : " + particulars,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(
              backgroundColor: Colors.green,
              color: Colors.white,
            )),
    );
  }
}
