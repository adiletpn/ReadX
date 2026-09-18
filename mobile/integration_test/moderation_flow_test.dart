import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:readx/core/providers.dart';
import 'package:readx/features/auth/auth_repository.dart';
import 'package:readx/features/feed/posts_repository.dart';
import 'package:readx/features/profile/users_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  final suffix = DateTime.now().millisecondsSinceEpoch;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  Future<void> signIn(String email, String password) async {
    final token = await container
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    await container.read(tokenStorageProvider).write(token);
  }

  testWidgets('report, block and delete run end to end against the API',
      (tester) async {
    final auth = container.read(authRepositoryProvider);
    final users = container.read(usersRepositoryProvider);
    final posts = container.read(postsRepositoryProvider);

    final aliceToken = await auth.register(
      name: 'Alice',
      surname: 'Reader',
      username: 'alice_$suffix',
      email: 'alice_$suffix@example.com',
      password: 'secret123',
    );
    await container.read(tokenStorageProvider).write(aliceToken);
    final alice = await auth.me();

    final bobToken = await auth.register(
      name: 'Bob',
      surname: 'Reader',
      username: 'bob_$suffix',
      email: 'bob_$suffix@example.com',
      password: 'secret123',
    );
    await container.read(tokenStorageProvider).write(bobToken);
    final bob = await auth.me();
    final bobPost = await posts.create(content: 'Пост от Боба');

    await signIn('alice_$suffix@example.com', 'secret123');

    final feedWithBob = await posts.feed(FeedTab.global);
    expect(feedWithBob.map((p) => p.id), contains(bobPost.id));

    await users.report(
      target: ReportTarget.post,
      targetId: bobPost.id,
      reason: ReportReason.spam,
    );

    await users.block(bob.id);
    final feedWithoutBob = await posts.feed(FeedTab.global);
    expect(feedWithoutBob.map((p) => p.id), isNot(contains(bobPost.id)));

    final blocked = await users.blockedUsers();
    expect(blocked.map((u) => u.id), contains(bob.id));

    expect(await users.search('bob_$suffix'), isEmpty);

    await users.unblock(bob.id);
    final feedBack = await posts.feed(FeedTab.global);
    expect(feedBack.map((p) => p.id), contains(bobPost.id));

    await users.deleteAccount('secret123');
    await expectLater(auth.me(), throwsA(anything));
    await expectLater(
      auth.login(email: 'alice_$suffix@example.com', password: 'secret123'),
      throwsA(anything),
    );

    expect(alice.username, 'alice_$suffix');
  });

  testWidgets('the server rejects profanity in a post', (tester) async {
    final auth = container.read(authRepositoryProvider);
    final posts = container.read(postsRepositoryProvider);

    final token = await auth.register(
      name: 'Carol',
      surname: 'Reader',
      username: 'carol_$suffix',
      email: 'carol_$suffix@example.com',
      password: 'secret123',
    );
    await container.read(tokenStorageProvider).write(token);

    await expectLater(posts.create(content: 'ты сука'), throwsA(anything));
    final clean = await posts.create(content: 'Дочитал Абая, рекомендую');
    expect(clean.content, 'Дочитал Абая, рекомендую');
  });
}
