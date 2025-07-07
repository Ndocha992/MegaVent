import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class StaffQRScannerResult extends StatelessWidget {
  final String scanResult;

  const StaffQRScannerResult({
    super.key,
    required this.scanResult,
  });

  @override
  Widget build(BuildContext context) {
    final isError =
        scanResult.contains('Error') ||
        scanResult.contains('already checked in');
    final isSuccess = !isError;

    return Container(
      padding: const EdgeInsets.all(16), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isSuccess ? AppConstants.successColor : AppConstants.errorColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSuccess
                    ? AppConstants.successColor
                    : AppConstants.errorColor)
                .withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12), // Smaller
            decoration: BoxDecoration(
              color: (isSuccess
                      ? AppConstants.successColor
                      : AppConstants.errorColor)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color:
                  isSuccess
                      ? AppConstants.successColor
                      : AppConstants.errorColor,
              size: 28, // Smaller icon
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isSuccess ? 'Check-in Successful!' : 'Check-in Failed',
            style: AppConstants.titleMedium.copyWith(
              color:
                  isSuccess
                      ? AppConstants.successColor
                      : AppConstants.errorColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            scanResult,
            style: AppConstants.bodyMedium.copyWith(
              color: AppConstants.primaryColor,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}