import 'dart:convert';

import 'package:flut/core/network/api_client.dart';
import 'package:flut/core/network/api_constants.dart';
import 'package:flut/core/network/token_storage.dart';
import 'package:flut/features/driver/wallet/models/driver_wallet.dart';
import 'package:flut/features/driver/wallet/models/driver_wallet_transaction.dart';

class WalletService {
  WalletService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? const ApiClient(),
        _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<DriverWallet> getWallet() async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.get(
      ApiConstants.walletUrl,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      return DriverWallet.fromJson(jsonBody);
    }

    throw WalletException(_readErrorMessage(response.body));
  }

  Future<List<DriverWalletTransaction>> getTransactions() async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.get(
      ApiConstants.walletTransactionsUrl,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonBody = jsonDecode(response.body) as List<dynamic>;
      return jsonBody
          .map(
            (item) => DriverWalletTransaction.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw WalletException(_readErrorMessage(response.body));
  }

  Future<void> topUpWallet({
    required int amount,
  }) async {
    final accessToken = await _readAccessToken();
    final response = await _apiClient.postJson(
      ApiConstants.walletTopUpUrl,
      body: {
        'amount_to_add': amount,
      },
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw WalletException(_readErrorMessage(response.body));
  }

  Future<String> _readAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const WalletException('تعذر التحقق من الجلسة الحالية. سجلي الدخول مرة أخرى.');
    }

    return accessToken;
  }

  String _readErrorMessage(String body) {
    if (body.isEmpty) {
      return 'تعذر تنفيذ طلب المحفظة حالياً.';
    }

    try {
      final jsonBody = jsonDecode(body) as Map<String, dynamic>;
      final detail = jsonBody['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
    } catch (_) {
      return 'تعذر تنفيذ طلب المحفظة حالياً.';
    }

    return 'تعذر تنفيذ طلب المحفظة حالياً.';
  }
}

class WalletException implements Exception {
  const WalletException(this.message);

  final String message;
}
