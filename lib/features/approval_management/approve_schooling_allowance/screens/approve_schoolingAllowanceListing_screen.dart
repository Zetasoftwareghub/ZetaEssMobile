import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zeta_ess/core/services/NavigationService.dart';
import 'package:zeta_ess/features/self_service/schooling_allowance/screens/schoolingAllowanceDetail_screen.dart';

import '../../../../core/common/widgets/customTileListing_widget.dart';
import '../../../../core/utils.dart';

class ApproveSchoolingAllowanceListingScreen extends StatelessWidget {
  final String title;

  const ApproveSchoolingAllowanceListingScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Column(
          children: [
            TabBar(
              tabAlignment: TabAlignment.center,
              isScrollable: true,
              tabs: listTabs.map((tab) => Tab(text: tab.tr())).toList(),

              indicatorColor: Colors.blue,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SchoolingAllowanceListView(),
                  SchoolingAllowanceListView(),
                  SchoolingAllowanceListView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SchoolingAllowanceListView extends StatelessWidget {
  const SchoolingAllowanceListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(12.r),
      itemCount: 8,
      itemBuilder: (context, index) {
        return InkWell(
          onTap:
              () => NavigationService.navigateToScreen(
                context: context,
                screen: SchoolingAllowanceDetailScreen(isLineManager: true),
              ),
          child: CustomTileListingWidget(
            text1: "10-Oct",
            subText1: "2025",
            text2: "School Bus Allowance",
            subText2: "Amount:  5000",
          ),
        );
      },
    );
  }
}
