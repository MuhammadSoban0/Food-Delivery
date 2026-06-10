import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/app_state.dart';
import '../../models/order.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  const DeliveryTrackingScreen({super.key});

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  // Mock delivery data - in real app this would come from API
  final List<Order> _mockOrders = [
    Order(
      id: 'ORD-001',
      items: [],
      total: 25.99,
      status: DeliveryStatus.confirmed,
      orderDate: DateTime.now().subtract(const Duration(minutes: 5)),
      estimatedDelivery: DateTime.now().add(const Duration(minutes: 25)),
      deliveryAddress: '123 Main St, Downtown',
      driverName: 'John Smith',
      driverPhone: '+1 234 567 8900',
    ),
    Order(
      id: 'ORD-002',
      items: [],
      total: 18.50,
      status: DeliveryStatus.delivered,
      orderDate: DateTime.now().subtract(const Duration(hours: 2)),
      estimatedDelivery: DateTime.now().subtract(const Duration(minutes: 30)),
      deliveryAddress: '456 Oak Ave, Uptown',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Delivery Tracking'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final activeOrders = _mockOrders.where((order) => 
        order.status != DeliveryStatus.delivered && 
        order.status != DeliveryStatus.cancelled).toList();
    
    // Get payment successful notifications from AppState and convert to orders
    final paymentNotifications = context.watch<AppState>().notifications
        .where((notification) => notification.title.contains('Payment Successful'))
        .toList();
    
    // Convert payment notifications to past orders
    final notificationOrders = paymentNotifications.map((notification) {
      // Extract order details from notification body
      final orderIdMatch = RegExp(r'#(ORD-\w+)').firstMatch(notification.body);
      final amountMatch = RegExp(r'\$(\d+\.\d+)').firstMatch(notification.body);
      
      return Order(
        id: orderIdMatch?.group(1) ?? 'ORD-${notification.id.substring(0, 6)}',
        items: [], // Empty for now - in real app this would be stored with the order
        total: amountMatch != null ? double.parse(amountMatch.group(1)!) : 0.0,
        status: DeliveryStatus.delivered, // Assume delivered for payment successful
        orderDate: notification.timestamp,
        estimatedDelivery: notification.timestamp.add(const Duration(minutes: 30)),
        deliveryAddress: 'Address from notification', // In real app, extract from notification or user profile
      );
    }).toList();
    
    // Combine mock past orders with notification orders
    final pastOrders = [
      ..._mockOrders.where((order) => 
          order.status == DeliveryStatus.delivered || 
          order.status == DeliveryStatus.cancelled).toList(),
      ...notificationOrders,
    ]..sort((a, b) => b.orderDate.compareTo(a.orderDate)); // Sort by date, newest first

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activeOrders.isNotEmpty) ...[
            _buildSectionTitle('Active Deliveries')
                .animate()
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 16),
            ...activeOrders.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildActiveOrderCard(entry.value)
                    .animate()
                    .fadeIn(delay: (200 * entry.key).ms)
                    .slideX(begin: -0.1, end: 0),
              );
            }),
            const SizedBox(height: 32),
          ],
          
          if (pastOrders.isNotEmpty) ...[
            _buildSectionTitle('Order History')
                .animate()
                .fadeIn(delay: 300.ms),
            const SizedBox(height: 16),
            ...pastOrders.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPastOrderCard(entry.value)
                    .animate()
                    .fadeIn(delay: (400 + 100 * entry.key).ms)
                    .slideX(begin: -0.1, end: 0),
              );
            }),
          ],
          
          if (activeOrders.isEmpty && pastOrders.isEmpty)
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimaryColor,
      ),
    );
  }

  Widget _buildActiveOrderCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ${order.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              _buildStatusChip(order.status),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress Timeline
          _buildDeliveryTimeline(order),
          const SizedBox(height: 20),
          
          // Delivery Info
          _buildDeliveryInfo(order),
          const SizedBox(height: 16),
          
          // Action Buttons
          if (order.status == DeliveryStatus.inTransit) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callDriver(order),
                    icon: const Icon(LucideIcons.phone, size: 16),
                    label: const Text('Call Driver'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _trackOnMap(order),
                    icon: const Icon(LucideIcons.mapPin, size: 16),
                    label: const Text('Track on Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPastOrderCard(Order order) {
    // Check if this order came from a notification (has default delivery address)
    final isFromNotification = order.deliveryAddress == 'Address from notification';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: order.status == DeliveryStatus.delivered
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  order.status == DeliveryStatus.delivered
                      ? LucideIcons.checkCircle2
                      : LucideIcons.xCircle,
                  color: order.status == DeliveryStatus.delivered
                      ? Colors.green
                      : Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Order ${order.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (isFromNotification) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'PAID',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(order.orderDate),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (order.total > 0) ...[
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  _buildStatusChip(order.status, isSmall: true),
                ],
              ),
            ],
          ),
          if (isFromNotification) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Payment confirmed - Order details from notification history',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(DeliveryStatus status, {bool isSmall = false}) {
    Color color;
    String text;
    
    switch (status) {
      case DeliveryStatus.confirmed:
        color = Colors.blue;
        text = 'Confirmed';
        break;
      case DeliveryStatus.preparing:
        color = Colors.orange;
        text = 'Preparing';
        break;
      case DeliveryStatus.ready:
        color = Colors.purple;
        text = 'Ready';
        break;
      case DeliveryStatus.inTransit:
        color = AppTheme.primaryColor;
        text = 'In Transit';
        break;
      case DeliveryStatus.delivered:
        color = Colors.green;
        text = 'Delivered';
        break;
      case DeliveryStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: isSmall ? 10 : 12,
        ),
      ),
    );
  }

  Widget _buildDeliveryTimeline(Order order) {
    final steps = [
      TimelineStep('Order Confirmed', DeliveryStatus.confirmed),
      TimelineStep('Preparing Food', DeliveryStatus.preparing),
      TimelineStep('Ready for Pickup', DeliveryStatus.ready),
      TimelineStep('Out for Delivery', DeliveryStatus.inTransit),
      TimelineStep('Delivered', DeliveryStatus.delivered),
    ];
    
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isActive = _getStatusIndex(order.status) >= _getStatusIndex(step.status);
        final isCurrent = _getStatusIndex(order.status) == _getStatusIndex(step.status);
        
        return _buildTimelineItem(
          step.title,
          isActive,
          isCurrent,
          isLast: index == steps.length - 1,
        );
      }).toList(),
    );
  }

  Widget _buildTimelineItem(String title, bool isActive, bool isCurrent, {bool isLast = false}) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
                shape: BoxShape.circle,
                border: isCurrent ? Border.all(
                  color: AppTheme.primaryColor,
                  width: 3,
                ) : null,
              ),
              child: isActive ? const Icon(
                LucideIcons.check,
                color: Colors.white,
                size: 12,
              ) : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? Colors.black87 : Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(LucideIcons.mapPin, size: 16, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          if (order.estimatedDelivery != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(LucideIcons.clock, size: 16, color: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  'Estimated: ${_formatTime(order.estimatedDelivery!)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
          if (order.driverName != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(LucideIcons.user, size: 16, color: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  'Driver: ${order.driverName}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              LucideIcons.truck,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Deliveries',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your delivery tracking will appear here',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  int _getStatusIndex(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.confirmed: return 0;
      case DeliveryStatus.preparing: return 1;
      case DeliveryStatus.ready: return 2;
      case DeliveryStatus.inTransit: return 3;
      case DeliveryStatus.delivered: return 4;
      case DeliveryStatus.cancelled: return -1;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours != 1 ? 's' : ''} ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  void _callDriver(Order order) {
    // In real app, this would initiate a phone call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${order.driverName}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _trackOnMap(Order order) {
    // In real app, this would open a map view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening map view...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class TimelineStep {
  final String title;
  final DeliveryStatus status;
  
  TimelineStep(this.title, this.status);
}