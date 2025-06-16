import 'package:cloud_firestore/cloud_firestore.dart';

class Loan {
  final String id;
  final String studentId;
  final String providerId;
  final String providerName;
  final String loanType;
  final String institutionName;
  final String mpesaPhone;
  final double amount;
  final String status;
  final String purpose;
  final double interestRate;
  final int termMonths;
  final double monthlyPayment;
  final double remainingBalance;
  final DateTime nextDueDate;
  final DateTime dueDate;
  final String mpesaTransactionCode;
  final String repaymentMethod;
  final DateTime repaymentStartDate;
  final double latePaymentPenaltyRate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Loan({
    required this.id,
    required this.studentId,
    required this.providerId,
    required this.providerName,
    required this.loanType,
    required this.institutionName,
    required this.mpesaPhone,
    required this.amount,
    required this.status,
    required this.purpose,
    required this.interestRate,
    required this.termMonths,
    required this.monthlyPayment,
    required this.remainingBalance,
    required this.nextDueDate,
    required this.dueDate,
    required this.mpesaTransactionCode,
    this.repaymentMethod = 'M-PESA',
    required this.repaymentStartDate,
    this.latePaymentPenaltyRate = 5.0, // 5% penalty
    required this.createdAt,
    required this.updatedAt,
  });

  factory Loan.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Loan(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      providerId: data['providerId'] ?? '',
      providerName: data['providerName'] ?? '',
      loanType: data['loanType'] ?? '',
      institutionName: data['institutionName'] ?? '',
      mpesaPhone: data['mpesaPhone'] ?? '',
      amount: data['amount']?.toDouble() ?? 0.0,
      status: data['status'] ?? 'PENDING',
      purpose: data['purpose'] ?? '',
      interestRate: data['interestRate']?.toDouble() ?? 0.0,
      termMonths: data['termMonths'] ?? 12,
      monthlyPayment: data['monthlyPayment']?.toDouble() ?? 0.0,
      remainingBalance: data['remainingBalance']?.toDouble() ?? 0.0,
      nextDueDate: data['nextDueDate']?.toDate() ?? DateTime.now(),
      
      dueDate: data['dueDate']?.toDate() ?? DateTime.now(),
      mpesaTransactionCode: data['mpesaTransactionCode'] ?? '',
      repaymentMethod: data['repaymentMethod'] ?? 'M-PESA',
      repaymentStartDate: data['repaymentStartDate']?.toDate() ?? DateTime.now(),
      latePaymentPenaltyRate: data['latePaymentPenaltyRate']?.toDouble() ?? 5.0,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'providerId': providerId,
      'providerName': providerName,
      'loanType': loanType,
      'institutionName': institutionName,
      'mpesaPhone': mpesaPhone,
      'amount': amount,
      'status': status,
      'purpose': purpose,
      'interestRate': interestRate,
      'termMonths': termMonths,
      'monthlyPayment': monthlyPayment,
      'remainingBalance': remainingBalance,
      'nextDueDate': nextDueDate,
      'dueDate': dueDate,
      'mpesaTransactionCode': mpesaTransactionCode,
      'repaymentMethod': repaymentMethod,
      'repaymentStartDate': repaymentStartDate,
      'latePaymentPenaltyRate': latePaymentPenaltyRate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Loan copyWith({
    String? id,
    String? studentId,
    String? providerId,
    String? providerName,
    String? loanType,
    String? institutionName,
    String? mpesaPhone,
    double? amount,
    String? status,
    String? purpose,
    double? interestRate,
    int? termMonths,
    double? monthlyPayment,
    double? remainingBalance,
    DateTime? nextDueDate,
    DateTime? dueDate,
    String? mpesaTransactionCode,
    String? repaymentMethod,
    DateTime? repaymentStartDate,
    double? latePaymentPenaltyRate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Loan(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      loanType: loanType ?? this.loanType,
      institutionName: institutionName ?? this.institutionName,
      mpesaPhone: mpesaPhone ?? this.mpesaPhone,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      purpose: purpose ?? this.purpose,
      interestRate: interestRate ?? this.interestRate,
      termMonths: termMonths ?? this.termMonths,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      dueDate: dueDate ?? this.dueDate,
      mpesaTransactionCode: mpesaTransactionCode ?? this.mpesaTransactionCode,
      repaymentMethod: repaymentMethod ?? this.repaymentMethod,
      repaymentStartDate: repaymentStartDate ?? this.repaymentStartDate,
      latePaymentPenaltyRate: latePaymentPenaltyRate ?? this.latePaymentPenaltyRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}