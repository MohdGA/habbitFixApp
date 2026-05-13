import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class CommunityPost {
  final String id;
  final String type; // MILESTONE | TIP | STRUGGLE | WIN
  final String title;
  final String content;
  final String? habitName;
  final int? streak;
  final int likeCount;
  final int commentCount;
  final String username;
  final String displayName;
  final DateTime createdAt;
  final bool userLiked;

  const CommunityPost({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.habitName,
    this.streak,
    required this.likeCount,
    required this.commentCount,
    required this.username,
    required this.displayName,
    required this.createdAt,
    this.userLiked = false,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final count = json['_count'] as Map<String, dynamic>? ?? {};
    return CommunityPost(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      habitName: json['habitName'] as String?,
      streak: json['streak'] as int?,
      likeCount: count['likes'] as int? ?? 0,
      commentCount: count['comments'] as int? ?? 0,
      username: user['username'] as String? ?? 'user',
      displayName: user['displayName'] as String? ?? 'User',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      userLiked: json['userLiked'] as bool? ?? false,
    );
  }
}

class CommunityComment {
  final String id;
  final String content;
  final String username;
  final String displayName;
  final DateTime createdAt;

  const CommunityComment({
    required this.id,
    required this.content,
    required this.username,
    required this.displayName,
    required this.createdAt,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return CommunityComment(
      id: json['id'] as String,
      content: json['content'] as String,
      username: user['username'] as String? ?? 'user',
      displayName: user['displayName'] as String? ?? 'User',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final communityFilterProvider = StateProvider<String?>((ref) => null);

final communityPostsProvider =
    FutureProvider.autoDispose<List<CommunityPost>>((ref) async {
  final dio = ref.watch(dioProvider);
  final filter = ref.watch(communityFilterProvider);
  final url =
      filter != null ? '/community?type=$filter' : '/community';
  final response = await dio.get(url);
  final posts = (response.data['posts'] as List<dynamic>)
      .map((p) => CommunityPost.fromJson(p as Map<String, dynamic>))
      .toList();
  return posts;
});

// Liked state is tracked per-card using local state seeded from server's userLiked field.

// ─── Screen ───────────────────────────────────────────────────────────────────

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityPostsProvider);
    final filter = ref.watch(communityFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        color: AppColors.orange,
        backgroundColor: AppColors.surface,
        onRefresh: () => ref.refresh(communityPostsProvider.future),
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              title: Text('Community'),
              pinned: true,
            ),

            // Filter chips
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                          label: 'All',
                          selected: filter == null,
                          onTap: () => ref
                              .read(communityFilterProvider.notifier)
                              .state = null),
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: '🏆 Milestone',
                          selected: filter == 'MILESTONE',
                          onTap: () => ref
                              .read(communityFilterProvider.notifier)
                              .state = 'MILESTONE'),
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: '💡 Tips',
                          selected: filter == 'TIP',
                          onTap: () => ref
                              .read(communityFilterProvider.notifier)
                              .state = 'TIP'),
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: '🎉 Wins',
                          selected: filter == 'WIN',
                          onTap: () => ref
                              .read(communityFilterProvider.notifier)
                              .state = 'WIN'),
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: '💪 Struggles',
                          selected: filter == 'STRUGGLE',
                          onTap: () => ref
                              .read(communityFilterProvider.notifier)
                              .state = 'STRUGGLE'),
                    ],
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              sliver: postsAsync.when(
                data: (posts) => posts.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('👥',
                                  style: TextStyle(fontSize: 64)),
                              const SizedBox(height: 16),
                              Text('No posts yet',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium),
                              const SizedBox(height: 8),
                              const Text(
                                'Be the first to share your journey!',
                                style: TextStyle(
                                    color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PostCard(post: posts[i])
                                .animate(
                                    delay: Duration(
                                        milliseconds: i * 60))
                                .fadeIn()
                                .slideY(begin: 0.1),
                          ),
                          childCount: posts.length,
                        ),
                      ),
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⚠️',
                            style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text('$e',
                            style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => ref
                              .refresh(communityPostsProvider.future),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePostSheet(context, ref),
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Share',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _showCreatePostSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CreatePostSheet(onCreated: () {
        ref.invalidate(communityPostsProvider);
      }),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.orange.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.orange : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.orange : AppColors.textSecondary,
            fontSize: 13,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─── Post Card ────────────────────────────────────────────────────────────────

class _PostCard extends ConsumerStatefulWidget {
  final CommunityPost post;
  const _PostCard({required this.post});

  @override
  ConsumerState<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<_PostCard> {
  bool _showComments = false;
  final _commentCtrl = TextEditingController();
  bool _submittingComment = false;
  List<CommunityComment> _comments = [];
  bool _loadingComments = false;
  late bool _isLiked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.userLiked;
    _likeCount = widget.post.likeCount;
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Color get _typeColor {
    switch (widget.post.type) {
      case 'MILESTONE':
        return AppColors.yellow;
      case 'WIN':
        return AppColors.green;
      case 'TIP':
        return AppColors.purple;
      case 'STRUGGLE':
        return AppColors.red;
      default:
        return AppColors.orange;
    }
  }

  String get _typeEmoji {
    switch (widget.post.type) {
      case 'MILESTONE':
        return '🏆';
      case 'WIN':
        return '🎉';
      case 'TIP':
        return '💡';
      case 'STRUGGLE':
        return '💪';
      default:
        return '📝';
    }
  }

  Future<void> _toggleLike() async {
    // Optimistic update
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      await ref.read(dioProvider).post('/community/${widget.post.id}/like', data: {});
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
          _likeCount += _isLiked ? 1 : -1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not like post: $e'), backgroundColor: AppColors.red),
        );
      }
    }
  }

  Future<void> _loadComments() async {
    setState(() => _loadingComments = true);
    try {
      final resp = await ref
          .read(dioProvider)
          .get('/community/${widget.post.id}/comments');
      final list = (resp.data['comments'] as List<dynamic>)
          .map((c) =>
              CommunityComment.fromJson(c as Map<String, dynamic>))
          .toList();
      if (mounted) setState(() => _comments = list);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingComments = false);
    }
  }

  Future<void> _submitComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _submittingComment = true);
    try {
      final resp = await ref
          .read(dioProvider)
          .post('/community/${widget.post.id}/comments',
              data: {'content': text});
      final comment = CommunityComment.fromJson(
          resp.data['comment'] as Map<String, dynamic>);
      _commentCtrl.clear();
      if (mounted) setState(() => _comments.add(comment));
    } catch (_) {
    } finally {
      if (mounted) setState(() => _submittingComment = false);
    }
  }

  void _toggleComments() {
    setState(() => _showComments = !_showComments);
    if (_showComments && _comments.isEmpty) _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = _isLiked;
    final displayLikes = _likeCount;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.xpGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.post.displayName.isNotEmpty
                          ? widget.post.displayName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.displayName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                      Text(
                        timeago.format(widget.post.createdAt),
                        style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11),
                      ),
                    ],
                  ),
                ),
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_typeEmoji ${widget.post.type}',
                    style: TextStyle(
                        color: _typeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.post.content,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5),
                ),
                if (widget.post.streak != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          color: AppColors.orange, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.post.streak} day streak',
                        style: const TextStyle(
                            color: AppColors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Row(
              children: [
                // Like
                TextButton.icon(
                  onPressed: _toggleLike,
                  icon: Icon(
                    isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isLiked ? AppColors.red : AppColors.textMuted,
                    size: 18,
                  ),
                  label: Text(
                    '$displayLikes',
                    style: TextStyle(
                      color: isLiked
                          ? AppColors.red
                          : AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ),
                // Comments toggle
                TextButton.icon(
                  onPressed: _toggleComments,
                  icon: const Icon(Icons.chat_bubble_outline_rounded,
                      color: AppColors.textMuted, size: 18),
                  label: Text(
                    '${widget.post.commentCount + (_comments.length > widget.post.commentCount ? _comments.length - widget.post.commentCount : 0)}',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Comments section
          if (_showComments) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  if (_loadingComments)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (_comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'No comments yet. Be the first!',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 13),
                      ),
                    )
                  else
                    ..._comments.map((c) => _CommentRow(comment: c)),

                  const SizedBox(height: 8),

                  // Comment input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Add a comment…',
                            hintStyle: const TextStyle(
                                color: AppColors.textMuted, fontSize: 14),
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.orange),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          onSubmitted: (_) => _submitComment(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _submitComment,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _submittingComment
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black),
                                )
                              : const Icon(Icons.send_rounded,
                                  color: Colors.black, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Comment Row ──────────────────────────────────────────────────────────────

class _CommentRow extends StatelessWidget {
  final CommunityComment comment;
  const _CommentRow({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                comment.displayName.isNotEmpty
                    ? comment.displayName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.displayName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    comment.content,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Create Post Sheet ────────────────────────────────────────────────────────

class _CreatePostSheet extends ConsumerStatefulWidget {
  final VoidCallback onCreated;
  const _CreatePostSheet({required this.onCreated});

  @override
  ConsumerState<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<_CreatePostSheet> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  String _selectedType = 'WIN';
  bool _loading = false;
  String? _error;

  final _types = [
    ('WIN', '🎉', 'Win', AppColors.green),
    ('MILESTONE', '🏆', 'Milestone', AppColors.yellow),
    ('TIP', '💡', 'Tip', AppColors.purple),
    ('STRUGGLE', '💪', 'Struggle', AppColors.red),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) {
      setState(() => _error = 'Title and content are required');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(dioProvider).post('/community', data: {
        'type': _selectedType,
        'title': title,
        'content': content,
      });
      widget.onCreated();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('Share with Community',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),

          // Type selector
          Text('Post type',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: _types.map((t) {
              final selected = _selectedType == t.$1;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedType = t.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? t.$4.withValues(alpha: 0.15)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? t.$4 : AppColors.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(t.$2,
                            style: const TextStyle(fontSize: 18)),
                        Text(
                          t.$3,
                          style: TextStyle(
                              color: selected
                                  ? t.$4
                                  : AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Title
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 15),
            decoration: _inputDecoration('Title'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),

          // Content
          TextField(
            controller: _contentCtrl,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14),
            decoration: _inputDecoration('Share your story…'),
            maxLines: 3,
            minLines: 3,
            textInputAction: TextInputAction.done,
          ),

          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!,
                style: const TextStyle(
                    color: AppColors.red, fontSize: 13)),
          ],
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black))
                  : const Text('Post',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: AppColors.textMuted, fontSize: 14),
      filled: true,
      fillColor: AppColors.surfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.orange, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
