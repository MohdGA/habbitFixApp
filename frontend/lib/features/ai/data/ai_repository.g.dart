// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiRepositoryHash() => r'17815333a76200ecf861ee0ca8c85aa5f99e9d40';

/// See also [aiRepository].
@ProviderFor(aiRepository)
final aiRepositoryProvider = AutoDisposeProvider<AiRepository>.internal(
  aiRepository,
  name: r'aiRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$aiRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiRepositoryRef = AutoDisposeProviderRef<AiRepository>;
String _$aiSuggestionsHash() => r'8c7823b5fbb2603ca51604a168a6ab6ca668f941';

/// See also [aiSuggestions].
@ProviderFor(aiSuggestions)
final aiSuggestionsProvider = AutoDisposeFutureProvider<List<String>>.internal(
  aiSuggestions,
  name: r'aiSuggestionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiSuggestionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiSuggestionsRef = AutoDisposeFutureProviderRef<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
