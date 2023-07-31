import 'package:payment_gateway_flutter/src/models/payment_state.dart';

class PaymentEvent{

  final PaymentState currentState;
  final bool success;
  final dynamic data;
  const PaymentEvent({required this.success, required this.currentState, required this.data});

}