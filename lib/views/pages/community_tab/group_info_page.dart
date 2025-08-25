import 'package:bet_u/views/widgets/chip_widget.dart';
import 'package:bet_u/views/widgets/long_button_widget.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class GroupInfoPage extends StatelessWidget {
  const GroupInfoPage({
    super.key,
    required this.groupName,
    this.nickname,
    this.memberCount,
    this.challengeCount,
    this.tags = const [],
    this.isPublic = true,
    this.description = '',
    this.image,
    this.onJoinPressed,
  });

  final String groupName;
  final String? nickname; // 그룹 닉네임
  final int? memberCount; // 예: 일일 68
  final int? challengeCount; // 예: 챌린지 17
  final List<String> tags;
  final bool isPublic;
  final String description;
  final ImageProvider<Object>? image;
  final VoidCallback? onJoinPressed;

  static const primaryGreen = Color(0xFF1BAB0F);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('그룹 정보'), centerTitle: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 썸네일
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3E9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: image != null
                      ? Image(image: image!, fit: BoxFit.cover)
                      : const Icon(
                          Icons.image,
                          size: 48,
                          color: Colors.black38,
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // 제목 카드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TitleBlock(
                        title: groupName,
                        subtitle: '그룹장 $nickname',
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (memberCount != null)
                          _StatItem(
                            label: '인원',
                            value: memberCount!.toString(),
                          ),
                        if (challengeCount != null) ...[
                          const SizedBox(width: 16),
                          _StatItem(
                            label: '챌린지',
                            value: challengeCount!.toString(),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 태그
              if (tags.isNotEmpty) ...[
                _SectionHeader(icon: Icons.tag, title: '그룹 태그'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((t) => ChipWidget(text: t)).toList(),
                ),
                const SizedBox(height: 20),
              ],

              // 공개 여부
              // _SectionHeader(icon: Icons.lock_outline, title: '공개 여부'),
              // const SizedBox(height: 8),

              // 상세 설명
              _SectionHeader(icon: Icons.description_outlined, title: '상세 설명'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  description.isEmpty ? '그룹 소개가 아직 없어요.' : description,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ),

      // 하단 긴 버튼
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: LongButtonWidget(
          text: '그룹 참여하기',
          onPressed: onJoinPressed ?? () {},
          backgroundColor: AppColors.primaryGreen,
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 6),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
