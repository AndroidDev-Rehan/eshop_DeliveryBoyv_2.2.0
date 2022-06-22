import 'dart:async';
import 'dart:convert';

import 'package:deliveryboy/Model/CashCollection_Model.dart';

//import 'package:deliveryboy/Model/Order_Model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'Helper/AppBtn.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'OrderDetail.dart';

class CashCollection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateCash();
  }
}

int? total, offset;
List<CashColl_Model> cashList = [];
bool _isLoading = true;
bool isLoadingmore = true;

class StateCash extends State<CashCollection> with TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  List<CashColl_Model> tempList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  ScrollController controller = new ScrollController();
  String? searchText;
  final TextEditingController _controller = TextEditingController();
  String _searchText = "", _lastsearch = "";
  bool isLoadingmore = true, isGettingdata = false, isNodata = false;

  @override
  void initState() {
    offset = 0;
    total = 0;
    cashList.clear();

    getOrder("", "DESC",);
    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(new CurvedAnimation(
      parent: buttonController!,
      curve: new Interval(
        0.0,
        0.150,
      ),
    ));
    controller.addListener(_scrollListener);
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        if (mounted) {
          setState(() {
            _searchText = "";
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _searchText = _controller.text;
          });
        }
      }

      if (_lastsearch != _searchText &&
          ((_searchText.length > 2) || (_searchText == ""))) {
        _lastsearch = _searchText;
        isLoadingmore = true;
        offset = 0;
        getOrder("delivery", "DESC");
      }
    });
    super.initState();
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          isLoadingmore = true;

          if (offset! < total!) getOrder("delivery", "DESC");
        });
      }
    }
  }

  Future<Null> getOrder(String from, String order) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (isLoadingmore) {
          if (mounted) {
            setState(() {
              isLoadingmore = false;
              isGettingdata = true;
              if (offset == 0) {
                cashList = [];
              }
            });
          }

          if (CUR_USERID != null) {
            var parameter = {
              DELIVERY_BOY_ID: CUR_USERID,
              STATUS: from == "delivery"
                  ? DELIVERY_BOY_CASH
                  : DELIVERY_BOY_CASH_COLL,
              LIMIT: perPage.toString(),
              OFFSET: offset.toString(),
              ORDER_BY: order,
              SEARCH: _searchText.trim(),
            };

            Response response =
                await post(getCashCollection, body: parameter, headers: headers)
                    .timeout(Duration(seconds: timeOut));

            var getdata = json.decode(response.body);

            bool error = getdata["error"];

            isGettingdata = false;
            if (offset == 0) isNodata = error;

            if (!error) {
              var data = getdata["data"];
              var dataDetails = getdata["data"][0]["order_details"];

              if (data.length != 0) {
                List<CashColl_Model> items = [];
                List<CashColl_Model> allitems = [];

                items.addAll((data as List)
                    .map((data) => CashColl_Model.fromJson(data))
                    .toList());

                allitems.addAll(items);

                for (CashColl_Model item in items) {
                  cashList.where((i) => i.id == item.id).map((obj) {
                    allitems.remove(item);
                    return obj;
                  }).toList();
                }
                cashList.addAll(allitems);

                isLoadingmore = true;
                offset = offset! + perPage;
              } else {
                isLoadingmore = false;
              }
            } else {
              isLoadingmore = false;
            }

            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          } else {
            if (mounted) if (mounted) {
              setState(() {
                isLoadingmore = false;
              });
            }
          }
        }
      } on TimeoutException catch (_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            isLoadingmore = false;
          });
        }
        setSnackbar(somethingMSg);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
          _isLoading = false;
        });
      }
    }

    return null;
  }

  setSnackbar(String msg) {
    _scaffoldKey.currentState!.showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: black),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
  }

  getAppBar(String title, BuildContext context) {
    return AppBar(
      leading: Builder(builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.all(10),
          decoration: shadow(),
          child: Card(
            elevation: 0,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => Navigator.of(context).pop(),
              child: Center(
                child: Icon(
                  Icons.keyboard_arrow_left,
                  color: primary,
                ),
              ),
            ),
          ),
        );
      }),
      title: Text(
        title,
        style: TextStyle(
          color: fontColor,
        ),
      ),
      backgroundColor: white,
      actions: [
        Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: shadow(),
            child: Card(
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    return orderSortDialog();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.swap_vert,
                      color: primary,
                      size: 22,
                    ),
                  ),
                ))),
        Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: shadow(),
            child: Card(
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    return filterDialog();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.tune,
                      color: primary,
                      size: 22,
                    ),
                  ),
                ))),
      ],
    );
  }

  void orderSortDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ButtonBarTheme(
            data: ButtonBarThemeData(
              alignment: MainAxisAlignment.center,
            ),
            child: new AlertDialog(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                contentPadding: const EdgeInsets.all(0.0),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                      padding: EdgeInsets.only(top: 19.0, bottom: 16.0),
                      child: Text(
                        ORDER_BY_TXT,
                        style: Theme.of(context).textTheme.headline6,
                      )),
                  Divider(color: lightBlack),
                  TextButton(
                      child: Text(ASC_TXT,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(color: lightBlack)),
                      onPressed: () {
                        cashList.clear();
                        offset = 0;
                        total = 0;
                        setState(() {
                          _isLoading = true;
                        });
                        getOrder("delivery", "ASC");
                        Navigator.pop(context, 'option 1');
                      }),
                  Divider(color: lightBlack),
                  TextButton(
                      child: Text(DESC_TXT,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(color: lightBlack)),
                      onPressed: () {
                        cashList.clear();
                        offset = 0;
                        total = 0;
                        setState(() {
                          _isLoading = true;
                        });
                        getOrder("delivery", "DESC");
                        Navigator.pop(context, 'option 1');
                      }),
                  Divider(
                    color: white,
                  )
                ])),
          );
        });
  }

  void filterDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ButtonBarTheme(
            data: ButtonBarThemeData(
              alignment: MainAxisAlignment.center,
            ),
            child: new AlertDialog(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                contentPadding: const EdgeInsets.all(0.0),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                      padding: EdgeInsets.only(top: 19.0, bottom: 16.0),
                      child: Text(
                        FILTER_BY,
                        style: Theme.of(context).textTheme.headline6,
                      )),
                  Divider(color: lightBlack),
                  TextButton(
                      child: Text(DELIVERY_BOY_CASH_TXT,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(color: lightBlack)),
                      onPressed: () {
                        cashList.clear();
                        offset = 0;
                        total = 0;
                        setState(() {
                          _isLoading = true;
                        });
                        getOrder("delivery", "DESC");
                        Navigator.pop(context, 'option 1');
                      }),
                  Divider(color: lightBlack),
                  TextButton(
                      child: Text(DELIVERY_BOY_CASH_COLL_TXT,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(color: lightBlack)),
                      onPressed: () {
                        cashList.clear();
                        offset = 0;
                        total = 0;
                        setState(() {
                          _isLoading = true;
                        });
                        getOrder("admin", "DESC");
                        Navigator.pop(context, 'option 1');
                      }),
                  Divider(
                    color: white,
                  )
                ])),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightWhite,
      appBar: getAppBar(CASH_COLL, context),
      body: _isNetworkAvail
          ? _isLoading
              ? shimmer()
              : SingleChildScrollView(
                  controller: controller,
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Card(
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.account_balance_wallet,
                                            color: fontColor,
                                          ),
                                          Text(
                                            " " + TOTAL_AMT,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2!
                                                .copyWith(
                                                color: fontColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Text(CUR_CURRENCY! + " " + cashList[0].cashReceived!,
                                          style: Theme.of(context).textTheme.headline6!.copyWith(
                                              color: fontColor, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )),
                            Container(
                                padding: EdgeInsetsDirectional.only(
                                    start: 5.0, end: 5.0,top: 10.0),
                                child: TextField(
                                  controller: _controller,
                                  decoration: InputDecoration(
                                    filled: true,
                                    isDense: true,
                                    fillColor: white,
                                    prefixIconConstraints: const BoxConstraints(
                                        minWidth: 40, maxHeight: 20),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    prefixIcon: Icon(Icons.search),
                                    hintText: FIND_ORDERS,
                                    hintStyle: TextStyle(
                                        color: black.withOpacity(0.3),
                                        fontWeight: FontWeight.normal),
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                  ),
                                )),
                            cashList.length == 0
                                ? isGettingdata
                                    ? Container()
                                    : Center(child: Text(noItem))
                                : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: (offset! < total!)
                                      ? cashList.length + 1
                                      : cashList.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    //totalAmt = cashList[index].cashReceived!;
                                    return (index == cashList.length &&
                                            isLoadingmore)
                                        ? Center(
                                            child:
                                                CircularProgressIndicator())
                                        : orderItem(index);
                                  },
                                ),
                            isGettingdata
                                ? Center(child: CircularProgressIndicator())
                                : Container(),
                          ])))
          : noInternet(context),
    );
  }

  orderItem(int index) {
    CashColl_Model model = cashList[index];
    Color back;
    if (model.type == "Collected") {
      back = Colors.green;
    } else {
      back = pink;
    }

    return Column(children: [
      InkWell(
        child: Card(
          elevation: 0,
          margin: EdgeInsets.all(5.0),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              AMT_LBL +
                                  " : " +
                                  CUR_CURRENCY! +
                                  " " +
                                  model.amount!,
                              style: TextStyle(
                                  color: fontColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text(model.date!),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            model.orderId! != "" && model.orderId! != null ?
                            Text(ORDER_ID_LBL + " : " + model.orderId!):Text(ID_LBL + " : " + model.id!),
                            Spacer(),
                            Container(
                              margin: EdgeInsets.only(left: 8),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                  color: back,
                                  borderRadius: new BorderRadius.all(
                                      const Radius.circular(4.0))),
                              child: Text(
                                capitalize(model.type!),
                                style: TextStyle(color: white),
                              ),
                            )
                          ],
                        ),
                        Text(MSG_LBL + " : " + model.message!),
                      ]))),
        ),
        onTap: () async {
          if (cashList[index].orderDetails != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      OrderDetail(model: cashList[index].orderDetails)),
            );
          }
        },
      ),

    ]);
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: TRY_AGAIN_INT_LBL,
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  getOrder("delivery", "DESC");
                } else {
                  await buttonController!.reverse();
                  setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }
}
