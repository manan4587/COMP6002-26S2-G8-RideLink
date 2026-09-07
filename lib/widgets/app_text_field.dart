import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/theme/app_text_style.dart';

import '../theme/app_style.dart';

class AppTextFormField extends StatelessWidget {
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? obscuringCharacter;
  final bool? obscureText;
  final bool? readOnly;
  final FocusNode? focusNode;
  final String? Function(dynamic value)? validator;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputAction? textInputAction;
  final TextAlign? textAlign;
  final TextStyle? style;
  final Widget? suffix;
  final bool? filled;
  final bool autoFocus;
  final bool? isDense;
  final void Function()? onTap;
  final void Function(String)? onFieldSubmit;
  final int? maxLength;
  final Widget? prefix;
  final double borderRadius;
  final Color errorBorderColor;
  final Color borderColor;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final List<TextInputFormatter>? inputFormatters;
  final String? label;

  const AppTextFormField({
    this.label,
    this.suffixIcon,
    this.prefixIcon,
    this.obscuringCharacter,
    this.obscureText,
    this.hintText,
    this.maxLines,
    this.readOnly,
    this.contentPadding,
    this.validator,
    this.keyboardType = TextInputType.text,
    required this.controller,
    super.key,
    this.textAlign,
    this.style,
    this.suffix,
    this.onTap,
    this.onFieldSubmit,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.filled = false,
    this.focusNode,
    this.minLines,
    this.textInputAction = TextInputAction.next,
    this.autoFocus = false,
    this.isDense,
    this.prefix,
    this.borderRadius = 8.0,
    this.errorBorderColor = AppColors.red,
    this.borderColor = AppColors.black,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[Text(label!, style: AppTextStyle.text16Medium)],
        Container(
          decoration: AppDecoration.textFieldDecoration,
          child: TextFormField(
            controller: controller,
            style: AppTextStyle.text16Medium,
            maxLines: maxLines ?? 1,
            readOnly: readOnly ?? false,
            textAlign: textAlign ?? TextAlign.start,
            onFieldSubmitted: onFieldSubmit,
            maxLength: maxLength,
            onChanged: onChanged,
            inputFormatters: inputFormatters,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            focusNode: focusNode,
            minLines: minLines,
            textInputAction: textInputAction,
            onSaved: onSaved,
            autofocus: autoFocus,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyle.text14Regular.copyWith(
                color: AppColors.grey,
              ),
              prefix: prefix,
              isDense: isDense,
              contentPadding:
                  contentPadding ??
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              filled: filled,
              suffixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: suffixIcon,
              ),
              suffix: suffix,
              prefixIcon: prefixIcon,
              errorMaxLines: 3,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
            obscuringCharacter: '*',
            obscureText: obscureText ?? false,
            keyboardType: keyboardType,
            cursorColor: AppColors.primaryColor,
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}

class AppNoteTextFormField extends StatelessWidget {
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? obscuringCharacter;
  final bool? obscureText;
  final bool? readOnly;
  final FocusNode? focusNode;
  final String? Function(dynamic value)? validator;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputAction? textInputAction;
  final TextAlign? textAlign;
  final TextStyle? style;
  final Widget? suffix;
  final bool? filled;
  final bool autoFocus;
  final bool? isDense;
  final void Function()? onTap;
  final void Function(String)? onFieldSubmit;
  final int? maxLength;
  final Widget? prefix;
  final double borderRadius;
  final Color errorBorderColor;
  final Color borderColor;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final List<TextInputFormatter>? inputFormatters;
  final String? label;

  const AppNoteTextFormField({
    this.label,
    this.suffixIcon,
    this.prefixIcon,
    this.obscuringCharacter,
    this.obscureText,
    this.hintText,
    this.maxLines,
    this.readOnly,
    this.contentPadding,
    this.validator,
    this.keyboardType = TextInputType.text,
    required this.controller,
    super.key,
    this.textAlign,
    this.style,
    this.suffix,
    this.onTap,
    this.onFieldSubmit,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.filled = false,
    this.focusNode,
    this.minLines,
    this.textInputAction = TextInputAction.next,
    this.autoFocus = false,
    this.isDense,
    this.prefix,
    this.borderRadius = 8.0,
    this.errorBorderColor = AppColors.red,
    this.borderColor = AppColors.black,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyle.text14Medium),
          8.verticalSpace,
        ],
        TextFormField(
          controller: controller,
          style: AppTextStyle.text16Medium,
          maxLines: maxLines ?? 1,
          readOnly: readOnly ?? false,
          textAlign: textAlign ?? TextAlign.start,
          onFieldSubmitted: onFieldSubmit,
          maxLength: maxLength,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          focusNode: focusNode,
          minLines: minLines,
          textInputAction: textInputAction,
          onSaved: onSaved,
          autofocus: autoFocus,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyle.text14Regular.copyWith(
              color: AppColors.grey,
            ),
            prefix: prefix,
            isDense: isDense,
            contentPadding:
                contentPadding ??
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: suffixIcon,
            ),
            suffix: suffix,
            prefixIcon: prefixIcon,
            errorMaxLines: 3,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.stroke),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.stroke),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.stroke),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.stroke),
            ),
          ),
          obscuringCharacter: '*',
          obscureText: obscureText ?? false,
          keyboardType: keyboardType,
          cursorColor: AppColors.primaryColor,
          onTap: onTap,
        ),
      ],
    );
  }
}
