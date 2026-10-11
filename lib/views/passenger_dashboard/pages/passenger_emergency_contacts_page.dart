import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/australian_phone_helper.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';
import 'package:ridelink/widgets/app_button.dart';
import 'package:ridelink/widgets/app_main_container.dart';

class PassengerEmergencyContactsPage
    extends GetView<PassengerDashboardController> {
  const PassengerEmergencyContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBgColor,
      body: AppMainContainer(
        alignment: AlignmentGeometry.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Navigation Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(
                            CupertinoIcons.back,
                            size: 22.sp,
                            color: AppColors.primaryTextColor,
                          ),
                          splashRadius: 22.r,
                        ),
                        Text(
                          'Emergency Contacts',
                          style: AppTextStyle.text18Semibold.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _showAddEditContactSheet(context),
                      icon: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      splashRadius: 22.r,
                    ),
                  ],
                ),

                12.verticalSpace,

                // Privacy Notice Banner (Visible to driver ONLY when ride is active)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.shield_lefthalf_fill,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Ride Privacy Protection',
                              style: AppTextStyle.text14Semibold.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            3.verticalSpace,
                            Text(
                              'Your emergency contacts are only visible to your driver while a trip is actively in progress. Before pickup and after trip completion, this data is strictly hidden.',
                              style: AppTextStyle.text12Regular.copyWith(
                                color: AppColors.secondaryTextColor,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                18.verticalSpace,

                // Contacts List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Trusted Contacts',
                      style: AppTextStyle.text16Semibold.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${controller.emergencyContacts.length} Added',
                        style: AppTextStyle.text12Medium.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),

                10.verticalSpace,

                Obx(() {
                  if (controller.emergencyContacts.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 36.h,
                        horizontal: 16.w,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.phone_badge_plus,
                            size: 44.sp,
                            color: AppColors.hintTextColor,
                          ),
                          12.verticalSpace,
                          Text(
                            'No Emergency Contacts Added',
                            style: AppTextStyle.text16Semibold,
                          ),
                          6.verticalSpace,
                          Text(
                            'Add a family member, partner, or close friend\nto notify in case of an emergency.',
                            textAlign: TextAlign.center,
                            style: AppTextStyle.text12Regular.copyWith(
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                          16.verticalSpace,
                          ElevatedButton.icon(
                            onPressed: () => _showAddEditContactSheet(context),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Contact'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.emergencyContacts.length,
                    separatorBuilder: (_, _) => 10.verticalSpace,
                    itemBuilder: (context, index) {
                      final contact = controller.emergencyContacts[index];
                      return _ContactCard(
                        contact: contact,
                        onEdit: () =>
                            _showAddEditContactSheet(context, contact),
                        onDelete: () =>
                            controller.removeEmergencyContact(contact.id),
                        onCall: () => Utils.launchCall(contact.phone),
                        onSetPrimary: () =>
                            controller.setPrimaryEmergencyContact(contact.id),
                      );
                    },
                  );
                }),

                24.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Modal Sheet to Add / Edit Emergency Contact
  void _showAddEditContactSheet(
    BuildContext context, [
    PassengerEmergencyContactModel? existingContact,
  ]) {
    final nameController = TextEditingController(
      text: existingContact?.name ?? '',
    );
    final phoneController = TextEditingController(
      text: existingContact != null
          ? AustralianPhoneHelper.stripToLocal(existingContact.phone)
          : '',
    );
    final RxString selectedRelation =
        (existingContact?.relation ?? 'Mother').obs;
    final RxBool isPrimary = (existingContact?.isPrimary.value ?? false).obs;

    final relations = [
      'Mother',
      'Father',
      'Spouse / Partner',
      'Sibling',
      'Friend',
      'Guardian',
      'Colleague',
      'Other',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.only(
            top: 14.h,
            left: 20.w,
            right: 20.w,
            bottom: MediaQuery.of(ctx).padding.bottom + 20.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              16.verticalSpace,
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.phone_badge_plus,
                      color: AppColors.primaryColor,
                      size: 22,
                    ),
                  ),
                  10.horizontalSpace,
                  Text(
                    existingContact == null
                        ? 'Add Emergency Contact'
                        : 'Edit Emergency Contact',
                    style: AppTextStyle.text18Semibold.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              16.verticalSpace,

              // Full Name
              Text('Contact Full Name', style: AppTextStyle.text12Semibold),
              6.verticalSpace,
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'e.g. Sarah Jenkins',
                  filled: true,
                  fillColor: AppColors.secondaryBgColor,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                ),
              ),

              14.verticalSpace,

              // Relationship with Person
              Text('Relationship with You', style: AppTextStyle.text12Semibold),
              8.verticalSpace,
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: relations.map((rel) {
                  return Obx(() {
                    final isSelected = selectedRelation.value == rel;
                    return GestureDetector(
                      onTap: () => selectedRelation.value = rel,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor
                              : AppColors.containerFillColor,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.borderColor,
                          ),
                        ),
                        child: Text(
                          rel,
                          style: AppTextStyle.text10Medium.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.primaryTextColor,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),

              14.verticalSpace,

              // Mobile Phone Number
              Text('Mobile Phone Number', style: AppTextStyle.text12Semibold),
              6.verticalSpace,
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\+')),
                  AustralianPhoneInputFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: '469 712 617',
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: AustralianPhonePrefix(
                      icon: const Icon(
                        CupertinoIcons.phone,
                        color: AppColors.secondaryTextColor,
                        size: 18,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  filled: true,
                  fillColor: AppColors.secondaryBgColor,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                ),
              ),

              12.verticalSpace,

              // Primary Toggle
              Obx(
                () => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isPrimary.value,
                  onChanged: (val) => isPrimary.value = val ?? false,
                  title: Text(
                    'Set as primary emergency contact',
                    style: AppTextStyle.text14Medium,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primaryColor,
                ),
              ),

              16.verticalSpace,

              // Save Button
              AppButton(
                label: existingContact == null
                    ? 'Save Emergency Contact'
                    : 'Update Contact',
                onPressed: () {
                  final name = nameController.text.trim();
                  final rawPhone = phoneController.text.trim();

                  if (name.isEmpty || rawPhone.isEmpty) {
                    AppSnackBar.error(
                      message:
                          'Please fill in both name and mobile phone number.',
                    );
                    return;
                  }

                  if (AustralianPhoneHelper.containsPlus(rawPhone)) {
                    AppSnackBar.error(
                      message: "'+' is not allowed. +61 is applied by default.",
                    );
                    return;
                  }

                  if (AustralianPhoneHelper.isIndianNumber(rawPhone)) {
                    AppSnackBar.error(
                      message:
                          "Numbers starting with 91 are not allowed. Australia (+61) only.",
                    );
                    return;
                  }

                  final cleanDigits =
                      AustralianPhoneHelper.cleanDigits(rawPhone);
                  if (cleanDigits.length < 9 || cleanDigits.length > 10) {
                    AppSnackBar.error(
                      message:
                          "Please enter a valid 9 or 10-digit Australian mobile number.",
                    );
                    return;
                  }

                  final phone =
                      AustralianPhoneHelper.formatToAustralian(rawPhone);

                  Get.back();

                  Future.delayed(const Duration(milliseconds: 250), () {
                    if (existingContact == null) {
                      controller.addEmergencyContact(
                        name: name,
                        relation: selectedRelation.value,
                        phone: phone,
                        isPrimary: isPrimary.value,
                      );
                    } else {
                      controller.updateEmergencyContact(
                        id: existingContact.id,
                        name: name,
                        relation: selectedRelation.value,
                        phone: phone,
                        isPrimary: isPrimary.value,
                      );
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CONTACT CARD
// ---------------------------------------------------------------------------
class _ContactCard extends StatelessWidget {
  final PassengerEmergencyContactModel contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCall;
  final VoidCallback onSetPrimary;

  const _ContactCard({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
    required this.onCall,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  contact.name.isNotEmpty ? contact.name[0] : 'C',
                  style: AppTextStyle.text16Semibold.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          contact.name,
                          style: AppTextStyle.text14Semibold.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        6.horizontalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            contact.relation,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    3.verticalSpace,
                    Text(
                      contact.phone,
                      style: AppTextStyle.text12Regular.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                if (contact.isPrimary.value) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: const Color(0xFFFCD34D)),
                    ),
                    child: Text(
                      'Primary',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  );
                }
                return IconButton(
                  onPressed: onSetPrimary,
                  tooltip: 'Make primary contact',
                  icon: const Icon(
                    Icons.star_outline_rounded,
                    size: 20,
                    color: AppColors.hintTextColor,
                  ),
                );
              }),
            ],
          ),

          10.verticalSpace,
          const Divider(color: AppColors.borderColor, height: 1),
          8.verticalSpace,

          // Actions Row (Call, Edit, Delete)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Call Button (Primary Action)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onCall,
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: const Color(0xFF86EFAC),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.phone_fill,
                          color: Color(0xFF15803D),
                          size: 14,
                        ),
                        6.horizontalSpace,
                        Text(
                          'Call',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Edit & Delete Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 7.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: AppColors.secondaryTextColor,
                            ),
                            4.horizontalSpace,
                            Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  8.horizontalSpace,
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 7.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: const Color(0xFFFECACA),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              size: 14,
                              color: Color(0xFFDC2626),
                            ),
                            4.horizontalSpace,
                            Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
