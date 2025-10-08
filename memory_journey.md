💞 BabyFace Memory Journal Specification (v2)
🌸 Overview

The Memory Journal is a warm, romantic space where couples record their shared milestones —
“first meet,” “first rose,” “first trip,” “first chocolate,” and more.

It’s not just a log — it’s a living journey of love.
Every entry adds a new glowing pin on their 3D romantic road, symbolizing how far their relationship has traveled.

Users can view memories as cards or switch to a visual journey preview, showing their love road — soft gradients, glowing markers, floating hearts, and “Forever Point 💍” at the end.

🎨 Visual Mood & Theme

Primary Colors:

Baby Pink → #FF6B81

Sky Blue → #6BCBFF

Cream Yellow → #FFE066

Lavender → #CDB4DB

Font Family: Handscup / BabyFont (from project theme)

Mood: Nostalgic, intimate, dreamy, warm

Tone: Realistic 3D with soft shadows and pastel lighting

Shape Motif: Heart pins, curved roads, gentle highlights

🏗️ Screen Architecture
Screen	Purpose
MemoryJournalHome	View & manage memories
AddMemoryScreen	Add new moment
MemoryDetailScreen	View/edit specific memory
JourneyPreviewScreen	3D roadmap visualization
MemoryVoicePlayer (optional)	Plays short voice memories
🧩 Folder Structure (Clean Architecture)
lib/
 └── features/
      └── memory_journal/
           ├── data/
           │    ├── models/
           │    │    └── memory_model.dart
           │    ├── sources/
           │    │    └── memory_local_source.dart  // Hive box CRUD
           │    └── repositories/
           │         └── memory_repository.dart
           ├── application/
           │    └── memory_provider.dart           // Riverpod state providers
           ├── presentation/
           │    ├── screens/
           │    │    ├── memory_journal_home.dart
           │    │    ├── add_memory_screen.dart
           │    │    ├── memory_detail_screen.dart
           │    │    └── journey_preview_screen.dart
           │    └── widgets/
           │         ├── memory_card.dart
           │         ├── heart_pin_marker.dart
           │         ├── road_painter.dart
           │         ├── animated_background.dart
           │         └── floating_hearts_layer.dart
           └── utils/
                └── journey_helper.dart

💾 Data Model (Hive)

Box Name: memory_box

class MemoryModel extends HiveObject {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String? photoPath;
  final String date;
  final String? voicePath;
  final String mood; // joyful, sweet, emotional
  final int positionIndex;
  final int timestamp;
}

⚙️ Riverpod State Management

memoryListProvider → Stream of all memories (sorted by timestamp)

addMemoryProvider → Handles new memory creation

deleteMemoryProvider → Deletes memory

selectedMemoryProvider → Currently viewed memory

journeyThemeProvider → Chooses color variant based on date/season

🧠 Business Logic Flow
➕ Add Memory

User taps ➕ button

Enters:

Title

Date (picker)

Emoji / Photo

Description

Mood (Sweet, Funny, Emotional)

Optional: short 10s voice note 🎤

“Save Memory” button animates softly

Data stored → Hive → triggers Riverpod update

📔 Memory Journal Home

Title: 💖 Our Memory Journal

Subtext: “Every memory tells our love story 🌸”

FloatingActionButton ➕ → Add Memory

List of memories:

Rounded pastel cards

Fade-in + scale animation

Each card: emoji/photo, title, date, short preview

Bottom Button: “Preview Journey 💞”

Actions:

Tap card → Memory Detail

Long press → Delete / Edit

“Preview Journey” → JourneyPreviewScreen

💌 Memory Detail Screen

Soft gradient background

Big title (emoji + text)

Memory date

Description card (baby pink background)

If photo: displayed in rounded frame

If voice: plays through soft pulse waveform

“Edit Memory” and “Delete” icons

Bottom heart animation: pulse slowly

🛣️ Journey Preview Screen (3D Road Visualization)

Goal: Present memories as a 3D love road with milestones.

Layout:

Title: 💞 Your Love Journey

Subtitle: “From your first meet to forever...”

Background: Animated pastel gradient

Foreground: 3D curved road (using CustomPainter or SVG path)

Along road: heart pins for each memory

Each Pin:

Shows emoji or photo thumbnail

Tap → floating card:

Memory title

Date

“Read Full Memory 💌” → opens detail screen

End of Road:

💍 “Forever Point” with sparkle animation

Message:

“Your next memory is waiting to be written...”
Button: Add New Memory 💞

Animations:

Road shimmer effect (Tween + blur)

Floating hearts above path

Heartbeat pulse when reaching major milestones

Subtle parallax movement while scrolling

Responsive:

Mobile → Vertical scroll

Tablet/Web → Horizontal

Auto-adjust road curvature

💕 Extra Engagement & Emotional Features
Feature	Description
🌈 Seasonal Themes	Road colors adapt to month (spring = pink, autumn = gold)
💬 Voice Memories	10s sound snippets stored per memory
🎧 Soft Music Loop	Gentle piano track during journey
💗 Heartbeat Animation	Screen pulses on key memories
✨ Magic Words	Floating “Forever”, “Love”, “Together” texts
💐 Mood Colors	Pins glow by memory mood
💞 Anniversary Counter	“Together for X days” banner
💌 Reminders	“Do you remember this day, one year ago?”
🩰 Couple Avatars	Optional animated couple moving along road
🕊️ Love Streaks	Motivates gentle daily entries
🕯️ Photo Glow Frame	Photos emit soft glow matching theme color
🧭 Navigation Flow
From	Action	To
Home	➕ Add Memory	Add Memory Screen
Home	Tap Memory	Memory Detail
Home	Preview Journey	Journey Preview
Journey	Tap Pin	Memory Detail
Detail	Back	Home
🧪 Testing Checklist

✅ Add/Edit/Delete memory
✅ Persist data with Hive
✅ Reactive updates with Riverpod
✅ Journey preview loads dynamically
✅ Animations <16ms per frame
✅ Theme follows dark/light mode
✅ Offline-safe Hive sync
✅ Scroll and gesture smoothness verified
✅ Voice & image playback tested

🧰 Technical Notes

Animation: AnimatedContainer, TweenAnimationBuilder, FadeTransition

Rendering: CustomPainter for road and markers

Storage: Hive lazy box for fast load

Architecture: MVVM pattern (Repository + Provider + UI)

Safety: Null-safe, no blocking calls, all UI async-free

Navigation: GoRouter or AppRouter

Theme Control: via Riverpod ThemeProvider

💖 Emotional Goal

“Every tap should feel like holding hands — every scroll, a shared heartbeat.”

Users shouldn’t feel like they’re managing data.
They should feel like they’re reliving love.

🎯 Deliverable Summary

4 Core Screens

Hive + Riverpod + Clean Architecture

Optimized for smooth 3D animations

Emotional + Romantic + Interactive

Zero Lottie, no external assets

Flutter-native only

🩷 End of Memory Journal v2 Specification

“Love isn’t a timeline — it’s a journey you build together.” 💞