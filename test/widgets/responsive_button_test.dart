import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_baby/shared/widgets/responsive_button.dart';

void main() {
  group('ResponsiveButton Tests', () {
    testWidgets('should display button text', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: ResponsiveButton(
                text: 'Test Button',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: ResponsiveButton(
                text: 'Test Button',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ResponsiveButton));
      expect(pressed, isTrue);
    });

    testWidgets('should show loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: ResponsiveButton(
                text: 'Test Button',
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should display icon when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: ResponsiveButton(
                text: 'Test Button',
                icon: Icons.star,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('should be disabled when isEnabled is false',
        (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: ResponsiveButton(
                text: 'Test Button',
                isEnabled: false,
                onPressed: () => pressed = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ResponsiveButton));
      expect(pressed, isFalse);
    });
  });
}
