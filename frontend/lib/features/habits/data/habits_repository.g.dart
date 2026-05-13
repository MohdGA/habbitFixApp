// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habits_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$habitsRepositoryHash() => r'dde70636f4bcb03b675846ada8510679851ca009';

/// See also [habitsRepository].
@ProviderFor(habitsRepository)
final habitsRepositoryProvider = AutoDisposeProvider<HabitsRepository>.internal(
  habitsRepository,
  name: r'habitsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$habitsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HabitsRepositoryRef = AutoDisposeProviderRef<HabitsRepository>;
String _$habitsHash() => r'ac2249e072d8617a53122b6f78cfdaa37c55e77c';

/// See also [habits].
@ProviderFor(habits)
final habitsProvider = AutoDisposeFutureProvider<HabitsData>.internal(
  habits,
  name: r'habitsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$habitsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HabitsRef = AutoDisposeFutureProviderRef<HabitsData>;
String _$habitsNotifierHash() => r'7d4dddd47335ace920afbd6bf7c7ce3efbaca070';

/// See also [HabitsNotifier].
@ProviderFor(HabitsNotifier)
final habitsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<HabitsNotifier, void>.internal(
  HabitsNotifier.new,
  name: r'habitsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$habitsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HabitsNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
