import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharma_app/features/order/models/order.dart';
import 'package:pharma_app/features/order/services/order_cache_services.dart';
import 'package:pharma_app/features/order/services/order_service.dart';
import 'order_state.dart';

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderApiService _apiService;
  final OrderCacheService _cacheService;

  OrderNotifier(this._apiService, this._cacheService)
      : super(const OrderInitial());

  /// Fetch all orders
  Future<void> fetchOrders(String token) async {
    state = const OrderLoading();
    try {
      final orders = await _apiService.fetchAllOrders(token: token);
      state = OrdersLoaded(orders);
      await _cacheService.saveOrders(orders);
    } catch (e) {
      // fallback to cache if API fails
      final cachedOrders = await _cacheService.getOrders();
      if (cachedOrders.isNotEmpty) {
        state = OrdersLoaded(cachedOrders);
      } else {
        state = OrderError(e.toString());
      }
    }
  }

  /// Fetch single order by ID
  Future<void> fetchOrderById(String token, String orderId) async {
    state = const OrderLoading();
    try {
      final order =
      await _apiService.fetchOrderById(token: token, orderId: orderId);
      state = OrderLoaded(order);
    } catch (e) {
      state = OrderError(e.toString());
    }
  }

  /// Create a new cash order
  Future<void> createCashOrder(
      String token,
      String cartId,
      Map<String, dynamic> shippingAddress,
      ) async {
    state = const OrderLoading();
    try {
      final order = await _apiService.createCashOrder(
        token: token,
        cartId: cartId,
        shippingAddress: shippingAddress,
      );
      state = OrderCreated(order);

      // also update cached orders
      final cachedOrders = await _cacheService.getOrders();
      final updatedOrders = [...cachedOrders, order];
      await _cacheService.saveOrders(updatedOrders);
    } catch (e) {
      state = OrderError(e.toString());
    }
  }

  /// Cancel/Delete an order
  Future<void> cancelOrder(String token, String orderId) async {
    state = const OrderLoading();
    try {
      await _apiService.cancelOrder(token: token, orderId: orderId);

      // update cache
      final cachedOrders = await _cacheService.getOrders();
      final updatedOrders =
      cachedOrders.where((order) => order.id != orderId).toList();
      await _cacheService.saveOrders(updatedOrders);

      state = OrderDeleted(orderId);
    } catch (e) {
      state = OrderError(e.toString());
    }
  }
}

final orderNotifierProvider =
StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final apiService = OrderApiService();
  final cacheService = OrderCacheService();
  return OrderNotifier(apiService, cacheService);
});
