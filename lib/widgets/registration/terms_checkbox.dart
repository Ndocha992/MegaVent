import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class TermsCheckbox extends StatelessWidget {
  final bool agreedToTerms;
  final ValueChanged<bool> onChanged;

  const TermsCheckbox({
    super.key,
    required this.agreedToTerms,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppConstants.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.gavel,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Terms & Conditions',
                style: AppConstants.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          const Text(
            'Please read and accept our terms to continue',
            style: AppConstants.bodyMediumSecondary,
          ),
          const SizedBox(height: 20),

          // Terms Agreement Checkbox
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: agreedToTerms 
                  ? AppConstants.successColor.withOpacity(0.05)
                  : AppConstants.backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: agreedToTerms 
                    ? AppConstants.successColor.withOpacity(0.3)
                    : AppConstants.borderColor,
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Checkbox
                GestureDetector(
                  onTap: () => onChanged(!agreedToTerms),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: agreedToTerms 
                          ? AppConstants.successColor 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: agreedToTerms 
                            ? AppConstants.successColor 
                            : AppConstants.borderColor,
                        width: 2,
                      ),
                    ),
                    child: agreedToTerms
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Terms Text
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppConstants.bodyMedium.copyWith(
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(
                          text: 'I agree to the ',
                        ),
                        TextSpan(
                          text: 'Terms of Service',
                          style: AppConstants.bodyMedium.copyWith(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _showTermsDialog(context, 'Terms of Service'),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: AppConstants.bodyMedium.copyWith(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _showTermsDialog(context, 'Privacy Policy'),
                        ),
                        const TextSpan(text: ' of MegaVent.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Key Points Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppConstants.primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppConstants.primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Key Points:',
                      style: AppConstants.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildKeyPoint('Your data is protected and secure'),
                _buildKeyPoint('You can delete your account anytime'),
                _buildKeyPoint('No spam - only relevant notifications'),
                _buildKeyPoint('Fair use policy for all users'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPoint(String point) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppConstants.successColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              point,
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppConstants.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppConstants.titleLarge,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTermsContent(title),
                    style: AppConstants.bodyMedium.copyWith(
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: AppConstants.primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Last updated: January 2025',
                            style: AppConstants.bodySmall.copyWith(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Close',
                style: AppConstants.bodyMedium.copyWith(
                  color: AppConstants.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppConstants.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'I Understand',
                  style: AppConstants.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getTermsContent(String title) {
    if (title == 'Terms of Service') {
      return '''
Welcome to MegaVent! These Terms of Service govern your use of our platform and services.

1. ACCEPTANCE OF TERMS
By accessing and using MegaVent, you accept and agree to be bound by the terms and provision of this agreement.

2. USER ACCOUNTS
- You must provide accurate and complete information when creating your account
- You are responsible for maintaining the confidentiality of your account credentials
- You must notify us immediately of any unauthorized use of your account

3. USER CONDUCT
- You agree to use MegaVent in compliance with all applicable laws and regulations
- You will not use the platform for any unlawful or prohibited activities
- You will not impersonate others or provide false information

4. EVENT ORGANIZERS
- Event organizers must provide accurate event information
- Organizers are responsible for the quality and safety of their events
- MegaVent reserves the right to remove events that violate our guidelines

5. ATTENDEE RESPONSIBILITIES
- Attendees must comply with event rules and regulations
- Attendees are responsible for their own safety during events
- Cancellation and refund policies are set by individual event organizers

6. PRIVACY AND DATA
- We collect and use your personal information as described in our Privacy Policy
- You consent to our collection and use of your information for platform services
- We implement security measures to protect your personal data

7. INTELLECTUAL PROPERTY
- MegaVent and its content are protected by intellectual property laws
- Users retain ownership of content they create on the platform
- By posting content, you grant us a license to use, display, and distribute it

8. LIMITATION OF LIABILITY
- MegaVent is provided "as is" without warranties of any kind
- We are not liable for any direct, indirect, incidental, or consequential damages
- Our liability is limited to the maximum extent permitted by law

9. TERMINATION
- Either party may terminate this agreement at any time
- We may suspend or terminate accounts that violate these terms
- Upon termination, your right to use the platform ceases immediately

10. CHANGES TO TERMS
- We reserve the right to modify these terms at any time
- Changes will be effective immediately upon posting
- Continued use of the platform constitutes acceptance of modified terms

For questions about these terms, please contact our support team at support@megavent.com.
      ''';
    } else {
      return '''
MegaVent Privacy Policy - Your privacy is important to us.

1. INFORMATION WE COLLECT
We collect information you provide directly to us, such as:
- Account registration information (name, email, phone number)
- Profile information and photos
- Event creation and participation data
- Communication preferences and settings

2. HOW WE USE YOUR INFORMATION
- To provide and maintain our services
- To process transactions and send related information
- To communicate with you about events and platform updates
- To improve our services and user experience
- To comply with legal obligations

3. INFORMATION SHARING
We do not sell, trade, or rent your personal information to third parties. We may share your information in the following circumstances:
- With event organizers when you register for their events
- With service providers who assist in platform operations
- When required by law or to protect our rights and safety
- In connection with a business transfer or acquisition

4. DATA SECURITY
We implement appropriate security measures to protect your personal information:
- Encryption of sensitive data in transit and at rest
- Regular security assessments and updates
- Access controls and authentication measures
- Secure data storage and backup procedures

5. YOUR RIGHTS AND CHOICES
- Access and update your account information
- Control your communication preferences
- Request deletion of your personal data
- Opt-out of certain data collection practices

6. COOKIES AND TRACKING
We use cookies and similar technologies to:
- Remember your preferences and settings
- Analyze platform usage and performance
- Provide personalized content and recommendations
- Ensure platform security and prevent fraud

7. DATA RETENTION
We retain your personal information for as long as necessary to:
- Provide our services to you
- Comply with legal obligations
- Resolve disputes and enforce agreements
- Maintain platform security and integrity

8. INTERNATIONAL DATA TRANSFERS
Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place to protect your data.

9. CHILDREN'S PRIVACY
Our platform is not intended for children under 13. We do not knowingly collect personal information from children under 13.

10. CHANGES TO PRIVACY POLICY
We may update this privacy policy from time to time. We will notify you of any material changes by posting the updated policy on our platform.

Contact us at privacy@megavent.com for any privacy-related questions or concerns.
      ''';
    }
  }
}