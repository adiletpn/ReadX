import 'package:flutter_test/flutter_test.dart';
import 'package:readx/core/api/endpoints.dart';
import 'package:readx/features/profile/users_repository.dart';

import '../../helpers/fake_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeBackend backend;
  late UsersRepository repo;

  setUp(() {
    backend = FakeBackend();
    repo = UsersRepository(buildTestClient(backend, token: 'jwt'));
  });

  group('profile', () {
    test('the nested posts inherit the author they are missing', () async {
      backend.on('GET', Endpoints.user(4), body: {
        'id': 4,
        'username': 'reader',
        'name': 'Бекзат',
        'surname': 'Ким',
        'avatar_url': '/uploads/a.png',
        'followersCount': 12,
        'isFollowing': 1,
        'posts': [
          {'id': 9, 'content': 'пост', 'likes': 2},
        ],
      });

      final profile = await repo.profile(4);

      expect(profile.displayName, 'Бекзат Ким');
      expect(profile.isFollowing, isTrue);
      expect(profile.posts.single.username, 'reader');
      expect(profile.posts.single.avatarUrl, '/uploads/a.png');
    });
  });

  group('search', () {
    test('sends the term as the q parameter', () async {
      backend.on('GET', Endpoints.userSearch, body: [
        {'id': 4, 'username': 'reader', 'name': 'Бекзат', 'total_points': 310},
      ]);

      final results = await repo.search('бек');

      expect(backend.lastRequest.query, {'q': 'бек'});
      expect(results.single.totalPoints, 310);
    });

    test('no matches is an empty list', () async {
      backend.on('GET', Endpoints.userSearch, body: const []);

      expect(await repo.search('zzz'), isEmpty);
    });
  });

  group('follow', () {
    test('returns the new state and the recounted followers', () async {
      backend.on('POST', Endpoints.userFollow(4), body: {'following': 1, 'followersCount': 13});

      final result = await repo.toggleFollow(4);

      expect(result.following, isTrue);
      expect(result.followersCount, 13);
    });

    test('followers and following read their own endpoints', () async {
      backend
        ..on('GET', Endpoints.userFollowers(4), body: [
          {'id': 1, 'username': 'a', 'isFollowing': 0},
        ])
        ..on('GET', Endpoints.userFollowing(4), body: [
          {'id': 2, 'username': 'b', 'isFollowing': 1},
        ]);

      expect((await repo.followers(4)).single.username, 'a');
      expect((await repo.following(4)).single.isFollowing, isTrue);
    });
  });

  group('updateProfile', () {
    test('sends the whole form, including the untouched fields', () async {
      backend.on('PUT', Endpoints.userProfile, body: {'ok': true});

      await repo.updateProfile(const ProfileFormData(
        username: 'reader',
        name: 'Бекзат',
        surname: 'Ким',
        bio: '',
        instagram: '',
        telegram: '',
        bookName: 'Дюна',
        bookAuthor: 'Герберт',
        showBook: true,
        bookCurrentPage: 120,
        bookTotalPages: 600,
      ));

      expect(backend.lastRequest.body, {
        'username': 'reader',
        'name': 'Бекзат',
        'surname': 'Ким',
        'bio': '',
        'instagram': '',
        'telegram': '',
        'book_name': 'Дюна',
        'book_author': 'Герберт',
        'show_book': 1,
        'book_current_page': 120,
        'book_total_pages': 600,
      });
    });

    test('the book toggle goes out as 0 or 1, not as a boolean', () async {
      backend.on('PUT', Endpoints.userProfile, body: {'ok': true});

      await repo.updateProfile(const ProfileFormData(
        username: 'reader',
        name: '',
        surname: '',
        bio: '',
        instagram: '',
        telegram: '',
        bookName: '',
        bookAuthor: '',
        showBook: false,
        bookCurrentPage: 0,
        bookTotalPages: 0,
      ));

      expect((backend.lastRequest.body! as Map)['show_book'], 0);
    });
  });
}
