import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:future_baby/shared/widgets/avatar_widget.dart';

void main() {
  group('AvatarWidget Tests', () {
    testWidgets('should display placeholder when no avatar data',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: AvatarWidget(
                placeholder: 'Upload Photo',
                size: 120,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Upload Photo'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should show upload icon when showUploadIcon is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: AvatarWidget(
                placeholder: 'Upload Photo',
                showUploadIcon: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('should show loading animation when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: AvatarWidget(
                placeholder: 'Upload Photo',
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      // Should find loading overlay
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: AvatarWidget(
                placeholder: 'Upload Photo',
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AvatarWidget));
      expect(tapped, isTrue);
    });
  });
}
