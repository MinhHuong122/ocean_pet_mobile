#!/bin/bash
# Quick Start Guide for Advanced Medical Records System
# Ocean Pet Mobile App - Medical Features v1.0

echo "🏥 Advanced Medical Records System - Quick Start"
echo "=============================================="
echo ""

# Step 1: Dependencies
echo "📦 Step 1: Installing dependencies..."
flutter clean
flutter pub get
echo "✅ Dependencies installed!"
echo ""

# Step 2: Code analysis
echo "🔍 Step 2: Code analysis..."
flutter analyze lib/services/health_score_service.dart
flutter analyze lib/services/pdf_service.dart
flutter analyze lib/services/share_service.dart
echo "✅ Code analysis complete!"
echo ""

# Step 3: Run app
echo "🚀 Step 3: Running app..."
flutter run
echo ""

# Step 4: Build APK
echo "📱 Step 4: Building APK (optional)..."
echo "Run: flutter build apk --release"
echo ""

echo "🎉 Setup complete! Medical records system is ready to use."
echo ""
echo "Features available:"
echo "  • Health Score (0-100)"
echo "  • PDF Export with QR code"
echo "  • Share via WhatsApp/Zalo/Email"
echo "  • AI Disease Detection (placeholder)"
echo ""
echo "Documentation:"
echo "  • MEDICAL_RECORDS_IMPLEMENTATION.md (detailed)"
echo "  • ADVANCED_MEDICAL_FEATURES.md (features overview)"
echo ""
