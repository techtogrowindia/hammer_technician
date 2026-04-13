import 'dart:io';

class KycStep4Response {
  final File aadharFront;
  final File aadharBack;
  final File panCard;
  final File bankStatement;
  final File photo;
  final File? gstDocument;

  KycStep4Response({
    required this.aadharFront,
    required this.aadharBack,
    required this.panCard,
    required this.bankStatement,
    required this.photo,
    this.gstDocument,
  });
}
