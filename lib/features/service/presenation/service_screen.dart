// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hammer_app/core/colors/colors.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Services"),
        backgroundColor: AppColors.primaryAmber,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text("Your Services Data Here")),
      ),
    );
  }

  }
