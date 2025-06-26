/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

class ErrorHandler {
  static void showErrorMessage(dynamic error) {
    final errorInfo = _extractErrorInfo(error);

    if (errorInfo['message'] ==
        'Erro inesperado: type \'Null\' is not a subtype of type \'String\'') {
      Get.snackbar(
        "Erro",
        errorInfo['message'] ?? '',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  static Map<String, String> _extractErrorInfo(dynamic error) {
    final errorMessage = error
        .toString()
        .replaceAll(RegExp(r'[{}]'), '')
        .replaceAll('Exception: ', '')
        .split(':');
    print("errorMessage: $errorMessage");
    try {
      return {
        'message': errorMessage[1] ?? 'Erro desconhecido',
      };
    } catch (e) {
      // Fallback para erros não formatados
      return {
        'message': error,
      };
    }
  }
}

*/
