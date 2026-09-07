import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ridelink/theme/app_text_style.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/app_loader.dart';
import '../data/models/ui/drop_down_model.dart';
import '../theme/app_style.dart';

class AppDropDown extends StatelessWidget {
  final String? hintText;
  final String? label;
  final Color? hintTextColor;
  final DropDownModel? selectedText;
  final String? prefixImage;
  final bool? isLoading;
  final List<DropDownModel>? items;
  final void Function(DropDownModel? value)? onChange;
  final String? Function(DropDownModel? value)? validator;

  const AppDropDown({
    super.key,
    this.hintText,
    this.label,
    this.selectedText,
    this.hintTextColor,
    this.prefixImage,
    this.isLoading,
    this.items,
    this.onChange,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyle.text14Medium),
          8.verticalSpace,
        ],
        Container(
          decoration: AppDecoration.textFieldDecoration,
          child: DropdownButtonFormField2<DropDownModel>(
            isDense: true,
            isExpanded: true,
            value: selectedText,
            validator: validator,
            alignment: Alignment.centerLeft,
            menuItemStyleData: MenuItemStyleData(
              padding: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              height: 32.h,
            ),
            dropdownStyleData: DropdownStyleData(
              padding: EdgeInsets.symmetric(vertical: defaultPadding / 2),
              elevation: 2,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
            ),
            hint: Text(
              hintText ?? "",
              style: AppTextStyle.text14Regular.copyWith(color: AppColors.grey),
            ),
            items: items!
                .map(
                  (item) => DropdownMenuItem<DropDownModel>(
                    value: item,
                    child: Text(item.title ?? ""),
                  ),
                )
                .toList(),
            onChanged: onChange,
            style: AppTextStyle.text14Medium,
            iconStyleData: IconStyleData(
              icon: isLoading ?? false
                  ? const CircularLoader()
                  : const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.borderColor,
                    ),
              openMenuIcon: const Icon(
                Icons.keyboard_arrow_up_rounded,
                color: AppColors.borderColor,
              ),
              iconSize: 26.h,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: defaultPadding,
                vertical: 10.h,
              ).copyWith(left: defaultPadding / 2),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              errorStyle: AppTextStyle.text14Regular.copyWith(
                color: AppColors.overdue,
              ),
              prefixIconConstraints: BoxConstraints.tight(const Size(40, 48)),
              prefixIcon: prefixImage == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 0, left: 16),
                      child: SvgPicture.asset(prefixImage ?? ""),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
