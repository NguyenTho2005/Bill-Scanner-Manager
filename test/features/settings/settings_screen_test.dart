import 'package:bill_tracker/core/di/injection_container.dart';
import 'package:bill_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await configureDependencies(environment: Env.test);
  });

  testWidgets('SettingsScreen renders all sections properly', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify section headers
    expect(find.text('Bảo mật & Quyền riêng tư'), findsOneWidget);
    expect(find.text('Dung lượng & Sao lưu'), findsOneWidget);
    expect(find.text('Đồng bộ hóa đám mây (Tùy chọn)'), findsOneWidget);
    expect(find.text('Vùng nguy hiểm'), findsOneWidget);

    // Verify key action tiles
    expect(find.text('Khóa sinh trắc học / PIN'), findsOneWidget);
    expect(find.text('Xuất dữ liệu Excel / CSV'), findsOneWidget);
    expect(find.text('Sao lưu toàn bộ (JSON)'), findsOneWidget);
    expect(find.text('Xóa toàn bộ dữ liệu'), findsOneWidget);
    expect(find.text('Bật đồng bộ đám mây'), findsOneWidget);
  });
}
