import 'product.dart';

enum DeliveryStatus {
  confirmed,
  preparing,
  ready,
  inTransit,
  delivered,
  cancelled,
}

class Order {
  final String id;
  final List<Product> items;  // Changed from CartItem to Product to match existing cart
  final double total;
  final DeliveryStatus status;
  final DateTime orderDate;
  final DateTime? estimatedDelivery;
  final String deliveryAddress;
  final String? driverName;
  final String? driverPhone;

  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.orderDate,
    this.estimatedDelivery,
    required this.deliveryAddress,
    this.driverName,
    this.driverPhone,
  });
}