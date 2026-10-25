import 'package:day_log/core/services/api_service.dart';
import 'package:flutter/material.dart';

class ApiTest extends StatefulWidget {
  const ApiTest({super.key});

  @override
  State<ApiTest> createState() => _ApiTestState();
}

class _ApiTestState extends State<ApiTest> {

  //todo통신 함수 테스트하기
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ApiService.tryLogin(email: 'daylog-test@example.com', password: 'DaylogTest123!');
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
