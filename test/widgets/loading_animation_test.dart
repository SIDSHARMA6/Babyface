import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_baby/shared/widgets/loading_animation.dart';

void main() {
  group('LoadingAnimation Tests', () {
    testWidgets('should display circular loading by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: LoadingAnimation(),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display text when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: LoadingAnimation(
                text: 'Loading...',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should display footprints animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: LoadingAnimation(
                type: LoadingType.footprints,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.pets_rounded), findsWidgets);
    });

    testWidgets('should display hearts animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: LoadingAnimation(
                type: LoadingType.hearts,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
    });

    testWidgets('should display bouncing animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: LoadingAnimation(
                type: LoadingType.bouncing,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.child_care_rounded), findsOneWidget);
    });
  });
}
