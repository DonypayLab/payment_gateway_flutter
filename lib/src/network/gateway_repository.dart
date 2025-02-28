import 'dart:convert';

import 'package:payment_gateway_flutter/payment_gateway_flutter.dart';
import 'package:payment_gateway_flutter/src/models/gateway_transaction.dart';
import 'package:payment_gateway_flutter/src/network/gateway_credentials.dart';
import 'package:payment_gateway_flutter/src/network/gateway_exception.dart';
import 'package:http/http.dart';

abstract class IGatewayRepository{

  Future<List<GatewayOperator>> findOperatorsByCountry(String baseUrl,String countryIso);

  Future<GatewayTransaction> createPayment({
    required String baseUrl,
    required String clientId,
    required String clientSecret,
    required int amount,
    required String currencyCode,
    required String merchantTransId,
    required String designation,
    String? customerRecipientNumber,
    String? customerEmail,
    String? customerFirstname,
    String? customerLastname
  });

  Future<GatewayTransaction> makePayment({
    required String baseUrl,
    required String clientId,
    required String clientSecret,
    required int amount,
    required String designation,
    required String gatewayOperatorCode,
    required String merchantTransId,
    required String customerRecipientNumber,
    String? customerEmail,
    String? customerFirstname,
    String? customerLastname,
    String? otp
  });
  Future<GatewayTransaction> makeTransfer({
    required String baseUrl,
    required String clientId,
    required String clientSecret,
    required int amount,
    required String gatewayOperatorCode,
    required String merchantTransId,
    required String customerRecipientNumber,
    String? customerEmail,
    String? customerFirstname,
    String? customerLastname
  });

  Future<GatewayTransaction> checkPaymentStatus( {
    required String baseUrl,
    required String clientId,
    required String clientSecret,
    required String merchantTransactionId
  });

}

class GatewayRepository implements IGatewayRepository{



  @override
  Future<GatewayTransaction> checkPaymentStatus({
    required  String baseUrl,
    required String clientId,
    required String clientSecret,
    required String merchantTransactionId
   })async {

    final authCredential = await GatewayCredentials().getAccessToken(baseUrl: baseUrl, clientId: clientId, clientSecret: clientSecret);


    final url = Uri.parse("$baseUrl/v1/gateway/payment/$merchantTransactionId");

    final response = await get(url,headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${authCredential.accessToken}'
    });

    print('checkPaymentStatus() =>>> REQ => ${response.body}');

    if(response.statusCode == 200){
      final Map<String, dynamic> json  = jsonDecode(response.body);
      final bool success = json['success'];
      if(success){
        final Map<String, dynamic> data = json['data'];
        return GatewayTransaction.fromJson(data);
      }else{

        throw GatewayException(
            message: json.containsKey('message')?json['message']:'',
            error: json.containsKey('error')?json['error']:'',
            code: json.containsKey('code')?json['code']:'',
            status: json.containsKey('status')?json['status']:''
        );
      }
    }else{

      if(response.headers['content-type'] == 'application/json'){
        final Map<String, dynamic> json  = jsonDecode(response.body);
        throw GatewayException(
            message: json.containsKey('message')?json['message']:'',
            error: json.containsKey('error')?json['error']:'',
            code: json.containsKey('code')?json['code']:'',
            status: json.containsKey('status')?json['status']:''
        );
      }else{
        throw response;
      }

    }
  }


  @override
  Future<List<GatewayOperator>> findOperatorsByCountry(String baseUrl,String countryIso)async {

    final url = Uri.parse("$baseUrl/v1/gateway/operators/$countryIso");

   final response = await get(url);
   if(response.statusCode == 200){
     final Map<String, dynamic> json  = jsonDecode(response.body);
     final bool success = json['success'];
     if(success){
       final List list = json['data'];
       final data = list.map((e) => GatewayOperator.fromJson(e as Map<String, dynamic>)).toList();
       return data;
     }else{
       throw response;
     }
   }else{
     throw response;
   }
  }

  @override
  Future<GatewayTransaction> makePayment({
    required String baseUrl,
    required String clientId,
    required String clientSecret,
    required int amount,
    required String designation,
    required String gatewayOperatorCode,
    required String merchantTransId,
    required String customerRecipientNumber,
    String? customerEmail,
    String? customerFirstname,
    String? customerLastname,
    String? otp})async {

    final authCredential = await GatewayCredentials().getAccessToken(baseUrl: baseUrl, clientId: clientId, clientSecret: clientSecret);

    final url = Uri.parse("$baseUrl/v1/gateway/make_payment");

    final response = await post(url,
    body: jsonEncode({
      "amount":amount,
      "designation":designation,
      "gateway_operator_code":gatewayOperatorCode,
      "merchant_trans_id":merchantTransId,
      "customer_recipient_number":customerRecipientNumber,
      "customer_email":customerEmail,
      "customer_firstname":customerFirstname,
      "customer_lastname":customerLastname,
      "otp":otp
    }),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${authCredential.accessToken}'
      }
    );

    print("makePayment() ==>>> BODY ${response.body}");

    if(response.statusCode == 200){
      final Map<String, dynamic> json  = jsonDecode(response.body);
      final bool success = json['success'];
      if(success){
        final Map<String, dynamic> data = json['data'];
        return GatewayTransaction.fromJson(data);
      }else{

        throw GatewayException(
          message: json.containsKey('message')?json['message']:'',
          error: json.containsKey('error')?json['error']:'',
          code: json.containsKey('code')?json['code']:'',
          status: json.containsKey('status')?json['status']:''
        );
      }
    }else{

      if(response.headers['content-type'] == 'application/json'){
        final Map<String, dynamic> json  = jsonDecode(response.body);
        throw GatewayException(
            message: json.containsKey('message')?json['message']:'',
            error: json.containsKey('error')?json['error']:'',
            code: json.containsKey('code')?json['code']:'',
            status: json.containsKey('status')?json['status']:''
        );
      }else{
        throw response;
      }

    }

  }

  @override
  Future<GatewayTransaction> makeTransfer({
    required String baseUrl,
    required String clientId,
    required String clientSecret,
    required int amount, required String gatewayOperatorCode, required String merchantTransId, required String customerRecipientNumber, String? customerEmail, String? customerFirstname, String? customerLastname})async {

    final authCredential = await GatewayCredentials().getAccessToken(baseUrl: baseUrl, clientId: clientId, clientSecret: clientSecret);

    final url = Uri.parse("$baseUrl/v1/gateway/make_transfer");

    final response = await post(url,
        body: jsonEncode({
          "amount":amount,
          "gateway_operator_code":gatewayOperatorCode,
          "merchant_trans_id":merchantTransId,
          "customer_recipient_number":customerRecipientNumber,
          "customer_email":customerEmail,
          "customer_firstname":customerFirstname,
          "customer_lastname":customerLastname,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authCredential.accessToken}'
        }
    );
    if(response.statusCode == 200){
      final Map<String, dynamic> json  = jsonDecode(response.body);
      final bool success = json['success'];
      if(success){
        final Map<String, dynamic> data = json['data'];
        return GatewayTransaction.fromJson(data);
      }else{

        throw GatewayException(
            message: json.containsKey('message')?json['message']:'',
            error: json.containsKey('error')?json['error']:'',
            code: json.containsKey('code')?json['code']:'',
            status: json.containsKey('status')?json['status']:''
        );
      }
    }else{

      if(response.headers['content-type'] == 'application/json'){
        final Map<String, dynamic> json  = jsonDecode(response.body);
        throw GatewayException(
            message: json.containsKey('message')?json['message']:'',
            error: json.containsKey('error')?json['error']:'',
            code: json.containsKey('code')?json['code']:'',
            status: json.containsKey('status')?json['status']:''
        );
      }else{
        throw response;
      }

    }
  }

  @override
  Future<GatewayTransaction> createPayment({
    required String baseUrl,
    required String clientId,
    required String clientSecret,
    required int amount,
    required String currencyCode,
    required String merchantTransId,
    required String designation,
    String? customerRecipientNumber,
    String? customerEmail,
    String? customerFirstname,
    String? customerLastname}) async{

    final authCredential = await GatewayCredentials().getAccessToken(baseUrl: baseUrl, clientId: clientId, clientSecret: clientSecret);

    final url = Uri.parse("$baseUrl/v1/gateway/create_payment");

    final response = await post(url,
        body: jsonEncode({
          "amount":amount,
          "currency_code":currencyCode,
          "merchant_trans_id":merchantTransId,
          "designation":designation,
          "customer_recipient_number":customerRecipientNumber,
          "customer_email":customerEmail,
          "customer_firstname":customerFirstname,
          "customer_lastname":customerLastname
        }),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authCredential.accessToken}'
        }
    );

    print("createPayment() ==>>> BODY ${response.body}");

    if(response.statusCode == 200){
      final Map<String, dynamic> json  = jsonDecode(response.body);
      final bool success = json['success'];
      if(success){
        final Map<String, dynamic> data = json['data'];
        return GatewayTransaction.fromJson(data);
      }else{

        throw GatewayException(
            message: json.containsKey('message')?json['message']:'',
            error: json.containsKey('error')?json['error']:'',
            code: json.containsKey('code')?json['code']:'',
            status: json.containsKey('status')?json['status']:''
        );
      }
    }else{

      if(response.headers['content-type'] == 'application/json'){
        final Map<String, dynamic> json  = jsonDecode(response.body);
        throw GatewayException(
            message: json.containsKey('message')?json['message']:'',
            error: json.containsKey('error')?json['error']:'',
            code: json.containsKey('code')?json['code']:'',
            status: json.containsKey('status')?json['status']:''
        );
      }else{
        throw response;
      }

    }
  }


}