import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/common/widgets/customElevatedButton_widget.dart';

class ExpenseClaimForm extends StatelessWidget {
  final VoidCallback? onDelete;

  const ExpenseClaimForm({super.key, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8.r)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Submitted Date', style: TextStyle(fontSize: 14.sp)),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
            ],
          ),
          SizedBox(height: 6.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text('16/08/2025', style: TextStyle(fontSize: 14.sp)),
          ),
          SizedBox(height: 12.h),
          _buildLabeledField(
            'Request Month & Year*',
            TextFormField(
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.calendar_today_outlined),
                hintText: '05 - 2025',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _buildLabeledField(
            'Amount*',
            TextFormField(
              initialValue: '5000',
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _buildLabeledField(
            'Expense Claim*',
            DropdownButtonFormField<String>(
              value: 'Canteen Allowance',
              items:
                  ['Canteen Allowance', 'Travel', 'Medical']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (_) {},
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _buildLabeledField(
            'Note',
            TextFormField(
              maxLines: 2,
              initialValue: 'Specific for me',
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: CustomElevatedButton(
              onPressed: () {},
              child: Text('Save Changes', style: TextStyle(fontSize: 14.sp)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField(String label, Widget field) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 14.sp)),
      SizedBox(height: 4.h),
      field,
    ],
  );
}
