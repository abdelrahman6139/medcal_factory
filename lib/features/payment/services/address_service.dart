// lib/services/address_service.dart
import 'package:dio/dio.dart';
import '../models/address.dart';

class AddressService {
  final Dio _dio;

  AddressService(String token)
      : _dio = Dio(BaseOptions(
    baseUrl: "http://localhost:5000/api/v1",
    headers: {"Authorization": "Bearer $token"},
  ));

  // Get logged user addresses
  Future<List<Address>> getAddresses() async {
    final response = await _dio.get("/addresses");
    return (response.data['data'] as List)
        .map((addr) => Address.fromJson(addr))
        .toList();
  }

  // Add address
  Future<List<Address>> addAddress(Address address) async {
    final response = await _dio.post("/addresses", data: address.toJson());
    return (response.data['data'] as List)
        .map((addr) => Address.fromJson(addr))
        .toList();
  }

  // Remove address
  Future<List<Address>> removeAddress(String addressId) async {
    final response = await _dio.delete("/addresses/$addressId");
    return (response.data['data'] as List)
        .map((addr) => Address.fromJson(addr))
        .toList();
  }
}
