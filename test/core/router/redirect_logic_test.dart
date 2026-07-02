import 'package:book_verse/core/router/redirect_logic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('computeRedirect', () {
    // ── L O A D I N G ──────────────────────────────────────────
    group('onBoardingStatus = loading', () {
      for (final loc in allLocations) {
        test('$loc → null', () {
          expect(
            computeRedirect(
              matchedLocation: loc,
              isAuthenticated: anyBool,
              onBoardingStatus: const AsyncLoading<bool>(),
            ),
            isNull,
          );
        });
      }
    });

    // ── E R R O R ──────────────────────────────────────────────
    group('onBoardingStatus = error', () {
      for (final loc in allLocations) {
        test('$loc → /error', () {
          expect(
            computeRedirect(
              matchedLocation: loc,
              isAuthenticated: anyBool,
              onBoardingStatus: AsyncError('fail', StackTrace.current),
            ),
            '/error',
          );
        });
      }
    });

    // ── D A T A (false)  x  isAuth=false ──────────────────────
    group('onBoardingStatus = data(false) | isAuth = false', () {
      for (final loc in locationsExpectOnboarding) {
        test('$loc → /onboarding', () {
          expect(
            computeRedirect(
              matchedLocation: loc,
              isAuthenticated: false,
              onBoardingStatus: const AsyncData(false),
            ),
            '/onboarding',
          );
        });
      }

      for (final loc in onboardingSubPaths) {
        test('$loc → null (stay on onboarding)', () {
          expect(
            computeRedirect(
              matchedLocation: loc,
              isAuthenticated: false,
              onBoardingStatus: const AsyncData(false),
            ),
            isNull,
          );
        });
      }
    });

    // ── D A T A (false)  x  isAuth=true ───────────────────────
    group('onBoardingStatus = data(false) | isAuth = true', () {
      for (final loc in locationsExpectOnboarding) {
        test('$loc → /onboarding (onboarding priority > auth)', () {
          expect(
            computeRedirect(
              matchedLocation: loc,
              isAuthenticated: true,
              onBoardingStatus: const AsyncData(false),
            ),
            '/onboarding',
          );
        });
      }

      for (final loc in onboardingSubPaths) {
        test('$loc → null', () {
          expect(
            computeRedirect(
              matchedLocation: loc,
              isAuthenticated: true,
              onBoardingStatus: const AsyncData(false),
            ),
            isNull,
          );
        });
      }
    });

    // ── D A T A (true)  x  isAuth=false ───────────────────────
    group('onBoardingStatus = data(true) | isAuth = false', () {
      for (final loc in locationsExpectLogin) {
        test('$loc → /login', () {
          expect(
            computeRedirect(
              matchedLocation: loc,
              isAuthenticated: false,
              onBoardingStatus: const AsyncData(true),
            ),
            '/login',
          );
        });
      }

      test('/login → null (stay on login)', () {
        expect(
          computeRedirect(
            matchedLocation: '/login',
            isAuthenticated: false,
            onBoardingStatus: const AsyncData(true),
          ),
          isNull,
        );
      });

      test('/onboarding → /login (onboarding done, needs auth)', () {
        expect(
          computeRedirect(
            matchedLocation: '/onboarding',
            isAuthenticated: false,
            onBoardingStatus: const AsyncData(true),
          ),
          '/login',
        );
      });

      for (final loc in onboardingSubPaths) {
        test('$loc → /login', () {
          expect(
            computeRedirect(
              matchedLocation: loc,
              isAuthenticated: false,
              onBoardingStatus: const AsyncData(true),
            ),
            '/login',
          );
        });
      }
    });

    // ── D A T A (true)  x  isAuth=true ────────────────────────
    group('onBoardingStatus = data(true) | isAuth = true', () {
      for (final loc in locationsStayAuthenticated) {
        test('$loc → null', () {
          expect(
            computeRedirect(
              matchedLocation: loc,
              isAuthenticated: true,
              onBoardingStatus: const AsyncData(true),
            ),
            isNull,
          );
        });
      }

      test('/login → /dashboard', () {
        expect(
          computeRedirect(
            matchedLocation: '/login',
            isAuthenticated: true,
            onBoardingStatus: const AsyncData(true),
          ),
          '/dashboard',
        );
      });

      for (final loc in onboardingSubPaths) {
        test('$loc → /dashboard', () {
          expect(
            computeRedirect(
              matchedLocation: loc,
              isAuthenticated: true,
              onBoardingStatus: const AsyncData(true),
            ),
            '/dashboard',
          );
        });
      }

      test('/bookmarks → /library', () {
        expect(
          computeRedirect(
            matchedLocation: '/bookmarks',
            isAuthenticated: true,
            onBoardingStatus: const AsyncData(true),
          ),
          '/library',
        );
      });
    });

    // ── C H A I N   T E S T  ────────────────────────────────
    group('chain — no infinite loop', () {
      for (final isAuth in [true, false]) {
        for (final hasOpened in [true, false]) {
          final label = 'isAuth=$isAuth hasOpened=$hasOpened';
          test(label, () {
            for (final loc in allLocations) {
              final chain = followChain(
                start: loc,
                isAuthenticated: isAuth,
                onBoardingStatus: AsyncData(hasOpened),
              );
              expect(
                chain,
                isNull,
                reason:
                    '$label starting at $loc: cycle detected in chain $chain',
              );
            }
          });
        }
      }
    });

    // ── A S Y N C   T R A N S I T I O N ──────────────────────
    group('async transition — loading → data(false)', () {
      test('loading at /login → null (safe)', () {
        expect(
          computeRedirect(
            matchedLocation: '/login',
            isAuthenticated: false,
            onBoardingStatus: const AsyncLoading<bool>(),
          ),
          isNull,
        );
      });

      test('resolve to data(false) at /login → /onboarding', () {
        expect(
          computeRedirect(
            matchedLocation: '/login',
            isAuthenticated: false,
            onBoardingStatus: const AsyncData(false),
          ),
          '/onboarding',
        );
      });

      test('/onboarding after resolve → null (stable)', () {
        expect(
          computeRedirect(
            matchedLocation: '/onboarding',
            isAuthenticated: false,
            onBoardingStatus: const AsyncData(false),
          ),
          isNull,
        );
      });
    });

    group('async transition — loading → data(true)', () {
      test('resolve to data(true) at /login → null (stay on login)', () {
        expect(
          computeRedirect(
            matchedLocation: '/login',
            isAuthenticated: false,
            onBoardingStatus: const AsyncData(true),
          ),
          isNull,
        );
      });
    });
  });
}

// ── H E L P E R S ──────────────────────────────────────────────

bool get anyBool => true; // both values are identical for loading/error

const allLocations = [
  '/',
  '/dashboard',
  '/login',
  '/onboarding',
  '/onboarding/2',
  '/onboarding/3',
  '/onboarding/4',
  '/explore',
  '/library',
  '/bookmarks',
  '/error',
  '/settings',
  '/search',
  '/detail/abc',
];

const locationsExpectOnboarding = [
  '/',
  '/dashboard',
  '/login',
  '/explore',
  '/library',
  '/bookmarks',
  '/error',
  '/settings',
  '/search',
  '/detail/abc',
];

const onboardingSubPaths = [
  '/onboarding',
  '/onboarding/2',
  '/onboarding/3',
  '/onboarding/4',
];

const locationsExpectLogin = [
  '/',
  '/dashboard',
  '/explore',
  '/library',
  '/bookmarks',
  '/error',
  '/settings',
  '/search',
  '/detail/abc',
];

const locationsStayAuthenticated = [
  '/',
  '/dashboard',
  '/explore',
  '/library',
  '/error',
  '/settings',
  '/search',
  '/detail/abc',
];

/// Follow redirect chain until stable (null) or cycle detected.
/// Returns null if chain stabilizes, or the repeated location if cycle found.
String? followChain({
  required String start,
  required bool isAuthenticated,
  required AsyncValue<bool> onBoardingStatus,
}) {
  final visited = <String>{};
  String? current = start;
  while (current != null) {
    if (!visited.add(current)) return current; // cycle detected
    current = computeRedirect(
      matchedLocation: current,
      isAuthenticated: isAuthenticated,
      onBoardingStatus: onBoardingStatus,
    );
  }
  return null; // stabilized
}
