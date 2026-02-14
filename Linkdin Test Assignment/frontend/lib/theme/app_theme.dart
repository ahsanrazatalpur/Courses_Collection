// import 'package:flutter/material.dart';

// class AppTheme {
//   // ==================== COLORS ====================
  
//   // Primary Colors
//   static const Color primaryIndigo = Color(0xFF3F51B5); // Indigo
//   static const Color primaryIndigoDark = Color(0xFF303F9F);
//   static const Color primaryIndigoLight = Color(0xFF7986CB);
  
//   // Accent/Hover Color
//   static const Color accentGreen = Color(0xFF4CAF50); // Green
//   static const Color accentGreenDark = Color(0xFF388E3C);
//   static const Color accentGreenLight = Color(0xFF81C784);
  
//   // Basic Colors
//   static const Color white = Color(0xFFFFFFFF);
//   static const Color black = Color(0xFF000000);
//   static const Color grey = Color(0xFF9E9E9E);
//   static const Color greyLight = Color(0xFFF5F5F5);
//   static const Color greyDark = Color(0xFF424242);
  
//   // Status Colors
//   static const Color errorRed = Color(0xFFF44336);
//   static const Color successGreen = Color(0xFF4CAF50);
//   static const Color warningOrange = Color(0xFFFF9800);
  
//   // ==================== LIGHT THEME ====================
  
//   static ThemeData lightTheme = ThemeData(
//     useMaterial3: true,
//     brightness: Brightness.light,
    
//     // Color Scheme
//     colorScheme: ColorScheme.light(
//       primary: primaryIndigo,
//       secondary: accentGreen,
//       error: errorRed,
//       background: white,
//       surface: white,
//       onPrimary: white,
//       onSecondary: white,
//       onBackground: black,
//       onSurface: black,
//     ),
    
//     scaffoldBackgroundColor: white,
    
//     // AppBar Theme
//     appBarTheme: AppBarTheme(
//       backgroundColor: primaryIndigo,
//       foregroundColor: white,
//       elevation: 2,
//       centerTitle: true,
//       titleTextStyle: TextStyle(
//         color: white,
//         fontSize: 20,
//         fontWeight: FontWeight.w600,
//       ),
//       iconTheme: IconThemeData(color: white),
//     ),
    
//     // Card Theme
//     cardTheme: CardThemeData(
//       color: white,
//       elevation: 2,
//       shadowColor: Colors.black.withOpacity(0.1),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       margin: EdgeInsets.all(8),
//     ),
    
//     // ==================== BUTTON THEMES WITH GREEN HOVER ====================
    
//     // Elevated Button - Indigo with GREEN HOVER
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ButtonStyle(
//         backgroundColor: MaterialStateProperty.resolveWith<Color>(
//           (Set<MaterialState> states) {
//             if (states.contains(MaterialState.hovered)) {
//               return accentGreen; // GREEN on hover
//             }
//             if (states.contains(MaterialState.pressed)) {
//               return accentGreenDark; // Darker green on press
//             }
//             return primaryIndigo; // Default indigo
//           },
//         ),
//         foregroundColor: MaterialStateProperty.all<Color>(white),
//         elevation: MaterialStateProperty.resolveWith<double>(
//           (Set<MaterialState> states) {
//             if (states.contains(MaterialState.hovered)) {
//               return 4; // More elevation on hover
//             }
//             return 2;
//           },
//         ),
//         padding: MaterialStateProperty.all<EdgeInsets>(
//           EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//         ),
//         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//           RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         textStyle: MaterialStateProperty.all<TextStyle>(
//           TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     ),
    
//     // Outlined Button - Indigo outline with GREEN HOVER
//     outlinedButtonTheme: OutlinedButtonThemeData(
//       style: ButtonStyle(
//         foregroundColor: MaterialStateProperty.resolveWith<Color>(
//           (Set<MaterialState> states) {
//             if (states.contains(MaterialState.hovered)) {
//               return accentGreen; // GREEN text on hover
//             }
//             return primaryIndigo; // Default indigo text
//           },
//         ),
//         side: MaterialStateProperty.resolveWith<BorderSide>(
//           (Set<MaterialState> states) {
//             if (states.contains(MaterialState.hovered)) {
//               return BorderSide(color: accentGreen, width: 2); // GREEN border on hover
//             }
//             return BorderSide(color: primaryIndigo, width: 2); // Default indigo border
//           },
//         ),
//         backgroundColor: MaterialStateProperty.resolveWith<Color>(
//           (Set<MaterialState> states) {
//             if (states.contains(MaterialState.hovered)) {
//               return accentGreen.withOpacity(0.1); // Light green background on hover
//             }
//             return Colors.transparent;
//           },
//         ),
//         padding: MaterialStateProperty.all<EdgeInsets>(
//           EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//         ),
//         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//           RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         textStyle: MaterialStateProperty.all<TextStyle>(
//           TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     ),
    
//     // Text Button - Indigo with GREEN HOVER
//     textButtonTheme: TextButtonThemeData(
//       style: ButtonStyle(
//         foregroundColor: MaterialStateProperty.resolveWith<Color>(
//           (Set<MaterialState> states) {
//             if (states.contains(MaterialState.hovered)) {
//               return accentGreen; // GREEN text on hover
//             }
//             return primaryIndigo; // Default indigo text
//           },
//         ),
//         backgroundColor: MaterialStateProperty.resolveWith<Color>(
//           (Set<MaterialState> states) {
//             if (states.contains(MaterialState.hovered)) {
//               return accentGreen.withOpacity(0.1); // Light green background on hover
//             }
//             return Colors.transparent;
//           },
//         ),
//         padding: MaterialStateProperty.all<EdgeInsets>(
//           EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         ),
//         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//           RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         textStyle: MaterialStateProperty.all<TextStyle>(
//           TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     ),
    
//     // Icon Button with GREEN HOVER
//     iconButtonTheme: IconButtonThemeData(
//       style: ButtonStyle(
//         iconColor: MaterialStateProperty.resolveWith<Color>(
//           (Set<MaterialState> states) {
//             if (states.contains(MaterialState.hovered)) {
//               return accentGreen; // GREEN icon on hover
//             }
//             return primaryIndigo; // Default indigo icon
//           },
//         ),
//         backgroundColor: MaterialStateProperty.resolveWith<Color>(
//           (Set<MaterialState> states) {
//             if (states.contains(MaterialState.hovered)) {
//               return accentGreen.withOpacity(0.1); // Light green background on hover
//             }
//             return Colors.transparent;
//           },
//         ),
//       ),
//     ),
    
//     // Floating Action Button with GREEN HOVER
//     floatingActionButtonTheme: FloatingActionButtonThemeData(
//       backgroundColor: primaryIndigo,
//       foregroundColor: white,
//       elevation: 4,
//       hoverColor: accentGreen, // GREEN on hover
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//     ),
    
//     // ==================== INPUT FIELDS ====================
    
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: greyLight,
//       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      
//       // Default border
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: grey, width: 1),
//       ),
      
//       // Enabled border
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: grey, width: 1),
//       ),
      
//       // Focused border - GREEN
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: accentGreen, width: 2),
//       ),
      
//       // Error border
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: errorRed, width: 1),
//       ),
      
//       // Focused error border
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: errorRed, width: 2),
//       ),
      
//       labelStyle: TextStyle(color: greyDark, fontSize: 16),
//       hintStyle: TextStyle(color: grey, fontSize: 16),
//       errorStyle: TextStyle(color: errorRed, fontSize: 13),
      
//       prefixIconColor: grey,
//       suffixIconColor: grey,
//     ),
    
//     // ==================== TEXT THEME ====================
    
//     textTheme: TextTheme(
//       // Large headings
//       headlineLarge: TextStyle(
//         fontSize: 32,
//         fontWeight: FontWeight.bold,
//         color: black,
//       ),
//       headlineMedium: TextStyle(
//         fontSize: 28,
//         fontWeight: FontWeight.bold,
//         color: black,
//       ),
//       headlineSmall: TextStyle(
//         fontSize: 24,
//         fontWeight: FontWeight.bold,
//         color: black,
//       ),
      
//       // Titles
//       titleLarge: TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.w600,
//         color: black,
//       ),
//       titleMedium: TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.w600,
//         color: black,
//       ),
//       titleSmall: TextStyle(
//         fontSize: 14,
//         fontWeight: FontWeight.w600,
//         color: black,
//       ),
      
//       // Body text
//       bodyLarge: TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.normal,
//         color: black,
//       ),
//       bodyMedium: TextStyle(
//         fontSize: 14,
//         fontWeight: FontWeight.normal,
//         color: black,
//       ),
//       bodySmall: TextStyle(
//         fontSize: 12,
//         fontWeight: FontWeight.normal,
//         color: greyDark,
//       ),
      
//       // Labels
//       labelLarge: TextStyle(
//         fontSize: 14,
//         fontWeight: FontWeight.w500,
//         color: black,
//       ),
//       labelMedium: TextStyle(
//         fontSize: 12,
//         fontWeight: FontWeight.w500,
//         color: black,
//       ),
//       labelSmall: TextStyle(
//         fontSize: 11,
//         fontWeight: FontWeight.w500,
//         color: grey,
//       ),
//     ),
    
//     // ==================== OTHER COMPONENTS ====================
    
//     // Icon Theme
//     iconTheme: IconThemeData(
//       color: greyDark,
//       size: 24,
//     ),
    
//     // Divider
//     dividerTheme: DividerThemeData(
//       color: grey.withOpacity(0.3),
//       thickness: 1,
//       space: 1,
//     ),
    
//     // Bottom Navigation Bar
//     bottomNavigationBarTheme: BottomNavigationBarThemeData(
//       backgroundColor: white,
//       selectedItemColor: primaryIndigo,
//       unselectedItemColor: grey,
//       selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
//       unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
//       type: BottomNavigationBarType.fixed,
//       elevation: 8,
//     ),
    
//     // Dialog
//     dialogTheme: DialogThemeData(
//       backgroundColor: white,
//       elevation: 8,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       titleTextStyle: TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//         color: black,
//       ),
//     ),
    
//     // Snackbar
//     snackBarTheme: SnackBarThemeData(
//       backgroundColor: greyDark,
//       contentTextStyle: TextStyle(color: white, fontSize: 14),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//       behavior: SnackBarBehavior.floating,
//     ),
    
//     // Progress Indicator
//     progressIndicatorTheme: ProgressIndicatorThemeData(
//       color: primaryIndigo,
//     ),
//   );
  
//   // ==================== DARK THEME ====================
  
//   static ThemeData darkTheme = ThemeData(
//     useMaterial3: true,
//     brightness: Brightness.dark,
    
//     colorScheme: ColorScheme.dark(
//       primary: primaryIndigoLight,
//       secondary: accentGreenLight,
//       error: errorRed,
//       background: greyDark,
//       surface: Color(0xFF303030),
//       onPrimary: black,
//       onSecondary: black,
//       onBackground: white,
//       onSurface: white,
//     ),
    
//     scaffoldBackgroundColor: greyDark,
    
//     // Same button hover effects for dark mode
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ButtonStyle(
//         backgroundColor: MaterialStateProperty.resolveWith<Color>(
//           (Set<MaterialState> states) {
//             if (states.contains(MaterialState.hovered)) {
//               return accentGreenLight; // GREEN on hover
//             }
//             if (states.contains(MaterialState.pressed)) {
//               return accentGreen;
//             }
//             return primaryIndigoLight;
//           },
//         ),
//         foregroundColor: MaterialStateProperty.all<Color>(black),
//         padding: MaterialStateProperty.all<EdgeInsets>(
//           EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//         ),
//         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//           RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//       ),
//     ),
//   );
// // }