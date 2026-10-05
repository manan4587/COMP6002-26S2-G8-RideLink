# RideLink Project Guidelines & Rules

## UI & UX Conventions

### 1. Zero Pop-Up Dialogs Rule (MANDATORY)
- **NEVER** use modal pop-up dialogs (`showDialog`, `AlertDialog`, `SimpleDialog`, `Dialog`, `Get.dialog`) in the RideLink application.
- **ALWAYS** use Bottom Sheets (`showModalBottomSheet` or `Get.bottomSheet`) for all interactions, including:
  - Confirmation prompts (e.g., Leave Community, Cancel Trip, Delete Account, Discard Changes)
  - Interactive forms & editors (e.g., Edit Trip Price & Seats, Set Custom Price, Add Saved Location)
  - Authentication sheets (e.g., Forgot Password)
  - Success/Arrival ratings and feedback
- **Bottom Sheet Standard Structure**:
  - `backgroundColor: Colors.transparent`
  - Rounded top corners: `BorderRadius.vertical(top: Radius.circular(24.r))`
  - Top drag handle pill: centered `Container(width: 44.w, height: 4.h, decoration: BoxDecoration(color: AppColors.borderColor, borderRadius: BorderRadius.circular(2.r)))`
  - Keyboard inset handling: `isScrollControlled: true` and `padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + ...)`
  - Destructive confirmations must feature a soft red icon (`Color(0xFFFEF2F2)` with `Color(0xFFDC2626)`), informative text, and clear "Cancel" vs destructive action buttons.

