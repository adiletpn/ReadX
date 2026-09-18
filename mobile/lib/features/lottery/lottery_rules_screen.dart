import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/pressable.dart';
import '../settings/app_settings.dart';

const _supportEmail = 'support@readx.kz';

class LotteryRulesScreen extends ConsumerWidget {
  const LotteryRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider).value ?? AppSettings.fallback;
    final threshold = settings.lotteryThreshold;
    final winners = settings.lotteryWinnerCount;

    return AppScaffold(
      header: AppHeader(
        leading: HeaderIconButton(
          icon: LucideIcons.arrowLeft,
          semanticLabel: 'Back',
          onTap: () => context.pop(),
        ),
        title: 'Правила розыгрыша',
        trailing: const SizedBox(width: 36),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          const Text(
            'ПРАВИЛА ЕЖЕМЕСЯЧНОГО РОЗЫГРЫША READX',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.primary30),
              borderRadius: BorderRadius.circular(AppMetrics.radiusCard),
            ),
            child: const Text(
              'Apple Inc. не является организатором, спонсором и никак не участвует '
              'в этом розыгрыше.',
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _Rule(
            number: '1',
            title: 'Организатор',
            body: 'Розыгрыш проводит ReadX, Республика Казахстан. '
                'Apple Inc. не является организатором, спонсором и не участвует '
                'в розыгрыше никаким образом.',
          ),
          const _Rule(
            number: '2',
            title: 'Участие бесплатное',
            body: 'Покупка чего-либо не требуется и не увеличивает шансы.',
          ),
          _Rule(
            number: '3',
            title: 'Кто участвует',
            body: 'Зарегистрированные пользователи ReadX, набравшие не менее '
                '$threshold очков за календарный месяц. Очки за приветственный '
                'бонус не учитываются.',
          ),
          const _Rule(
            number: '4',
            title: 'Период',
            body: 'Календарный месяц по времени Астаны (UTC+5), с 1-го числа 00:00 '
                'до последнего дня 23:59.',
          ),
          _Rule(
            number: '5',
            title: 'Определение победителей',
            body: '$winners ${_winnersWord(winners)} выбираются случайным образом '
                'среди всех квалифицировавшихся в течение 5 рабочих дней после '
                'окончания месяца. Позиция в рейтинге на шансы не влияет.',
          ),
          const _Rule(
            number: '6',
            title: 'Призы',
            body: 'Фирменный мерч ReadX. Денежный эквивалент не выплачивается, '
                'приз не подлежит обмену.',
          ),
          const _Rule(
            number: '7',
            title: 'Уведомление и вручение',
            body: 'Победителям сообщаем через уведомление в приложении и по email '
                'в течение 5 дней. Приз вручается в течение 30 дней по территории '
                'Республики Казахстан. Доставка за счёт организатора.',
          ),
          const _Rule(
            number: '8',
            title: 'Ограничения',
            body: 'К участию не допускаются сотрудники организатора и члены их семей. '
                'Участник может быть дисквалифицирован за накрутку очков, создание '
                'нескольких аккаунтов или нарушение правил сообщества.',
          ),
          const _Rule(
            number: '9',
            title: 'Персональные данные',
            body: 'Для вручения приза победитель предоставляет имя и контактные '
                'данные. Они используются только для доставки приза.',
          ),
          const _Rule(
            number: '10',
            title: 'Изменения',
            body: 'Организатор вправе изменить правила, опубликовав новую версию '
                'в приложении. Действует редакция на момент начала месяца.',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Вопросы: ',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Pressable(
                onTap: () => launchUrl(Uri.parse('mailto:$_supportEmail')),
                child: const Text(
                  _supportEmail,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _winnersWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'победитель';
    if ([2, 3, 4].contains(count % 10) && !(count % 100 >= 12 && count % 100 <= 14)) {
      return 'победителя';
    }
    return 'победителей';
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.number, required this.title, required this.body});

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. $title',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
