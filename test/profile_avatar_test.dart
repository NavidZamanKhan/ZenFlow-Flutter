import 'package:flutter_test/flutter_test.dart';
import 'package:zenflow_flutter/core/constants/api_endpoints.dart';
import 'package:zenflow_flutter/features/auth/models/user_model.dart';
import 'package:zenflow_flutter/features/profile/bloc/profile_bloc.dart';
import 'package:zenflow_flutter/features/profile/bloc/profile_event.dart';
import 'package:zenflow_flutter/features/profile/models/user_profile.dart';
import 'package:zenflow_flutter/features/profile/services/profile_service.dart';

class FakeProfileService extends ProfileService {
  UserProfile _profile = const UserProfile(
    fullName: 'Navid Zaman',
    username: 'navid',
    email: 'navid@zenflow.app',
    avatarUrl: null,
  );

  @override
  Future<UserProfile?> getProfile() async => _profile;

  @override
  Future<void> saveLocalProfile(UserProfile profile) async {
    _profile = profile;
  }

  @override
  Future<void> updateProfile({required UserProfile profile}) async {
    _profile = profile;
  }

  @override
  Future<UserProfile> uploadAvatar({required String imagePath}) async {
    _profile = _profile.copyWith(
      avatarUrl: '${ApiEndpoints.baseUrl}/media/avatars/test_avatar.jpg',
    );
    return _profile;
  }

  @override
  Future<UserProfile> deleteAvatar() async {
    _profile = _profile.copyWith(clearAvatar: true);
    return _profile;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Profile Avatar Engine Tests', () {
    test('Check 1: UserModel.resolveAvatarUrl parses relative & absolute paths', () {
      expect(UserModel.resolveAvatarUrl(null), isNull);
      expect(UserModel.resolveAvatarUrl(''), isNull);
      expect(
        UserModel.resolveAvatarUrl('https://custom-cdn.com/avatar.jpg'),
        'https://custom-cdn.com/avatar.jpg',
      );
      expect(
        UserModel.resolveAvatarUrl('/media/avatars/photo.jpg'),
        '${ApiEndpoints.baseUrl}/media/avatars/photo.jpg',
      );
      expect(
        UserModel.resolveAvatarUrl('media/avatars/photo.jpg'),
        '${ApiEndpoints.baseUrl}/media/avatars/photo.jpg',
      );
    });

    test('Check 2: UserProfile copyWith and clearAvatar logic', () {
      const initial = UserProfile(
        fullName: 'Navid Zaman',
        username: 'navid',
        email: 'navid@zenflow.app',
        avatarUrl: 'https://zenflow.app/avatar.jpg',
      );

      expect(initial.avatarUrl, 'https://zenflow.app/avatar.jpg');

      final updated = initial.copyWith(avatarUrl: 'https://zenflow.app/new.jpg');
      expect(updated.avatarUrl, 'https://zenflow.app/new.jpg');

      final cleared = updated.copyWith(clearAvatar: true);
      expect(cleared.avatarUrl, isNull);
    });

    test('Check 3: ProfileBloc handles UploadAvatarEvent and DeleteAvatarEvent', () async {
      final fakeService = FakeProfileService();
      final bloc = ProfileBloc(service: fakeService);

      expect(bloc.state.profile.avatarUrl, isNull);

      // Upload avatar
      bloc.add(const UploadAvatarEvent('/tmp/selected_image.jpg'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(
        bloc.state.profile.avatarUrl,
        '${ApiEndpoints.baseUrl}/media/avatars/test_avatar.jpg',
      );
      expect(bloc.state.isUploadingAvatar, isFalse);

      // Delete avatar
      bloc.add(const DeleteAvatarEvent());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.profile.avatarUrl, isNull);
      expect(bloc.state.isUploadingAvatar, isFalse);

      await bloc.close();
    });
  });
}
