import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminInitService {
  static const _adminEmail = 'abelmaeba5@gmail.com';
  static const _adminPassword = 'AbelMaeba';
  static const _adminFlagDoc = 'admin_init_flags';

  static Future<void> initializeAdmin() async {
    final firestore = FirebaseFirestore.instance;
    final flagsDoc = firestore.collection('system').doc(_adminFlagDoc);

    try {
      // Check if admin already exists
      final doc = await flagsDoc.get();
      if (doc.exists && doc.data()?['admin_created'] == true) {
        return;
      }

      // Initialize secondary Firebase app for admin creation
      final secondaryApp = await Firebase.initializeApp(
        name: 'AdminInitApp',
        options: Firebase.app().options,
      );
      
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      
      // Create admin user
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: _adminEmail,
        password: _adminPassword,
      );
      
      // Update user profile
      await credential.user!.updateDisplayName('Admin User');
      
      // Create admin record
      await firestore.collection('admins').doc(credential.user!.uid).set({
        'id': credential.user!.uid,
        'fullName': 'Abel Maeba',
        'email': _adminEmail,
        'isApproved': true,
        'adminLevel': 'superadmin',
        'permissions': ['all'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Create user record
      await firestore.collection('users').doc(credential.user!.uid).set({
        'id': credential.user!.uid,
        'fullName': 'Abel Maeba',
        'email': _adminEmail,
        'role': 'admin',
        'isApproved': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Send verification email
      await credential.user!.sendEmailVerification();
      
      // Set creation flag
      await flagsDoc.set({'admin_created': true, 'timestamp': FieldValue.serverTimestamp()});
      
      print('Admin user created successfully');
    } catch (e) {
      print('Admin creation error: $e');
    } finally {
      // Clean up secondary app
      try {
        await Firebase.app('AdminInitApp').delete();
      } catch (_) {}
    }
  }
}