import 'package:deliveryboy/Helper/String.dart';
import 'package:intl/intl.dart';

import 'Order_Model.dart';

class CashColl_Model {
  String? id,
      name,
      mobile,
      orderId,
      cashReceived,
      type,
      amount,
      message,
      transDate,
      date;
  Order_Model? orderDetails;
  //List<OrderItem>? itemList;

  CashColl_Model(
      {this.id,
      this.name,
      this.mobile,
      //this.itemList,
      this.date,
      this.type,
      this.message,
      this.amount,
      this.cashReceived,
      this.orderId,
      this.transDate,this.orderDetails});

  factory CashColl_Model.fromJson(Map<String, dynamic> parsedJson) {
    Order_Model? orderDetails;

    orderDetails = parsedJson['order_details'] != ""
        ? new Order_Model.fromJson(parsedJson['order_details'])
        : null;

    return new CashColl_Model(
        id: parsedJson[ID],
        name: parsedJson[NAME],
        mobile: parsedJson[MOBILE],
        type: parsedJson[TYPE],
        date: parsedJson[DATE_DEL],
        amount: parsedJson[AMOUNT],
        cashReceived: parsedJson[CASH_RECEIVED],
        message: parsedJson[MESSAGE],
        orderId: parsedJson[ORDERID],
        transDate: parsedJson[TRANS_DATE],
    orderDetails: orderDetails);
  }
}

class OrderDetail_Model {
  String? id,
      userId,
      deliveryBoyId,
      addressId,
      mobile,
      total,
      deliveryCharge,
      isDeliveryChargeReturnable,
      walletBalance,
      promoCode,
      promoDiscount,
      discount,
      totalPayable,
      finalTotal,
      paymentMethod,
      latitude,
      longitude,
      address,
      deliveryTime,
      deliveryDate,
      activeStatus,
      dateAdded,
      otp,
      notes,
      username,
      countryCode,
      name,
      courierAgency,
      trackingId,
      url,
      isReturnable,
      isCancelable,
      isAlreadyReturned,
      isAlreadyCancelled,
      returnRequestSubmitted,
      totalTaxPercent,
      totalTaxAmount;
  List<String?>? listStatus = [];
  List<String?>? listDate = [];
  List<OrderItem>? itemList;

  List<Attachment>? attachList = [];

  OrderDetail_Model(
      {this.attachList,
        this.listDate,
        this.listStatus,
        this.id,
        this.userId,
        this.deliveryBoyId,
        this.addressId,
        this.mobile,
        this.total,
        this.deliveryCharge,
        this.isDeliveryChargeReturnable,
        this.walletBalance,
        this.promoCode,
        this.promoDiscount,
        this.discount,
        this.totalPayable,
        this.finalTotal,
        this.paymentMethod,
        this.latitude,
        this.longitude,
        this.address,
        this.deliveryTime,
        this.deliveryDate,
        this.activeStatus,
        this.dateAdded,
        this.otp,
        this.notes,
        this.username,
        this.countryCode,
        this.name,
        this.courierAgency,
        this.trackingId,
        this.url,
        this.isReturnable,
        this.isCancelable,
        this.isAlreadyReturned,
        this.isAlreadyCancelled,
        this.returnRequestSubmitted,
        this.totalTaxPercent,
        this.totalTaxAmount,
        this.itemList});

  factory OrderDetail_Model.fromJson(Map<String, dynamic> json) {
    List<String?> lStatus = [];
    List<String?> lDate = [];

    var allStatus = json[STATUS];
    for (var curStatus in allStatus) {
      lStatus.add(curStatus[0]);
      lDate.add(curStatus[1]);
    }
    List<Attachment> attachmentList = [];

    var attachments = (json[ATTACHMENTS] as List);

    if (attachments == null || attachments.isEmpty)
      attachmentList = [];
    else
      attachmentList =
          attachments.map((data) => new Attachment.fromJson(data)).toList();

    String? date = json[DATE_ADDED];
    date = DateFormat('dd-MM-yyyy').format(DateTime.parse(date!));

    List<OrderItem> itemList = [];
    var order = (json[ORDER_ITEMS] as List?);
    if (order == null || order.isEmpty)
      order = [];
    else
      itemList = order.map((data) => new OrderItem.fromJson(data)).toList();

    return new OrderDetail_Model(
      id: json[ID],
      userId: json[USER_ID],
      deliveryBoyId: json[DELIVERY_BOY_ID],
      mobile: json[MOBILE],
      total: json[TOTAL],
      deliveryCharge: json[DELIVERY_CHARGE],
      attachList: attachmentList,
      listStatus: lStatus,
      listDate: lDate,
      itemList: itemList,
      paymentMethod: json[PAYMENT_METHOD],
      isCancelable: json[ISCANCLEABLE],
      isReturnable: json[ISRETURNABLE],
      dateAdded: json[DATE_ADDED]
    );
  }
}

class Attachment {
  String? id, attachment, bankTranStatus;

  Attachment({this.id, this.attachment, this.bankTranStatus});

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
        id: json[ID],
        attachment: json[ATTACHMENT],
        bankTranStatus: json[BANK_STATUS]);
  }
}
