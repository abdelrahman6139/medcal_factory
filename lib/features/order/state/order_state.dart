import 'package:pharma_app/features/order/models/order.dart';

/// Base state for all Order states
abstract class OrderState {
  const OrderState();
}

/// Initial state (nothing loaded yet)
class OrderInitial extends OrderState {
  const OrderInitial();
}

/// Loading state (fetching orders or performing an action)
class OrderLoading extends OrderState {
  const OrderLoading();
}

/// State when all orders are loaded successfully
class OrdersLoaded extends OrderState {
  final List<Order> orders;

  const OrdersLoaded(this.orders);
}

/// State when a single order is loaded successfully
class OrderLoaded extends OrderState {
  final Order order;

  const OrderLoaded(this.order);
}

/// State when an order is created successfully
class OrderCreated extends OrderState {
  final Order order;

  const OrderCreated(this.order);
}

/// State when an order is deleted/cancelled successfully
class OrderDeleted extends OrderState {
  final String orderId;

  const OrderDeleted(this.orderId);
}

/// Error state (any operation failed)
class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);
}
